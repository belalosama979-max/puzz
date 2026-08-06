import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/buzz_event_model.dart';
import '../../../domain/models/packet_model.dart';
import '../../../domain/models/room_model.dart';
import '../../../domain/models/round_model.dart';
import '../../../domain/models/statistics_model.dart';
import '../../../domain/models/team_model.dart';
import '../../../modules/networking/host_server.dart';
import '../../../modules/buzz/buzz_engine.dart';
import '../../../modules/timer/timer_engine.dart';
import '../../../modules/audio/audio_service.dart';
import '../../../modules/storage/storage_repository.dart';

class GameState {
  const GameState({
    this.currentRound,
    this.rounds = const [],
    this.winner,
    this.roomState = RoomState.waiting,
    this.roundState = RoundState.idle,
    this.roundNumber = 0,
    this.buzzEvents = const [],
    this.isPaused = false,
    this.isEnded = false,
  });

  final RoundModel? currentRound;
  final List<RoundModel> rounds;
  final TeamModel? winner;
  final RoomState roomState;
  final RoundState roundState;
  final int roundNumber;
  final List<BuzzEventModel> buzzEvents;
  final bool isPaused;
  final bool isEnded;

  bool get hasWinner => winner != null;
  bool get isBuzzerOpen => roundState == RoundState.open;

  GameState copyWith({
    RoundModel? currentRound,
    List<RoundModel>? rounds,
    TeamModel? winner,
    RoomState? roomState,
    RoundState? roundState,
    int? roundNumber,
    List<BuzzEventModel>? buzzEvents,
    bool? isPaused,
    bool? isEnded,
    bool clearWinner = false,
  }) => GameState(
        currentRound: currentRound ?? this.currentRound,
        rounds: rounds ?? this.rounds,
        winner: clearWinner ? null : (winner ?? this.winner),
        roomState: roomState ?? this.roomState,
        roundState: roundState ?? this.roundState,
        roundNumber: roundNumber ?? this.roundNumber,
        buzzEvents: buzzEvents ?? this.buzzEvents,
        isPaused: isPaused ?? this.isPaused,
        isEnded: isEnded ?? this.isEnded,
      );
}

class GameViewModel extends StateNotifier<GameState> {
  GameViewModel({
    required this.server,
    required this.buzzEngine,
    required this.timerEngine,
    required this.audio,
    required this.storage,
  }) : super(const GameState()) {
    _subscribeToBuzzEngine();
    _subscribeToServerEvents();
  }

  final HostServer server;
  final BuzzEngine buzzEngine;
  final TimerEngine timerEngine;
  final AudioService audio;
  final StorageRepository storage;

  StreamSubscription? _winnerSub;
  StreamSubscription? _serverSub;

  List<TeamModel> _connectedTeams = [];
  String _roomCode = '';
  String _competitionName = '';
  DateTime? _competitionStartedAt;

  void setRoomInfo(String code, String name) {
    _roomCode = code;
    _competitionName = name;
    _competitionStartedAt = DateTime.now();
    state = state.copyWith(roomState: RoomState.active);
  }

  void _subscribeToBuzzEngine() {
    _winnerSub = buzzEngine.onWinner.listen((result) async {
      if (!result.isWinner) return;

      // Find the winning team model.
      final winnerTeam = _connectedTeams.firstWhere(
        (t) => t.id == result.event.teamId,
        orElse: () => TeamModel(
          id: result.event.teamId,
          name: result.event.teamName,
          color: 0xFF6C63FF,
          avatar: 'lion',
        ),
      );

      // Update round with winner.
      final updated = state.currentRound?.copyWith(
        winnerTeamId: result.event.teamId,
        winnerTeamName: result.event.teamName,
        winnerReactionMs: result.event.reactionTimeMs,
      );

      state = state.copyWith(
        winner: winnerTeam,
        roundState: RoundState.answered,
        currentRound: updated,
      );

      // Broadcast winner to all teams.
      await server.broadcast(PacketModel(
        type: PacketType.winner,
        senderId: 'host',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        sequenceNumber: 0,
        payload: {
          'teamId': result.event.teamId,
          'teamName': result.event.teamName,
          'reactionTimeMs': result.event.reactionTimeMs,
          'teamColor': winnerTeam.color,
        },
      ));

      // Lock all teams.
      await server.broadcast(PacketModel(
        type: PacketType.lock,
        senderId: 'host',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        sequenceNumber: 0,
      ));

      await audio.playWinner();
    });
  }

  void _subscribeToServerEvents() {
    _serverSub = server.events.listen((update) {
      if (update.event == HostServerEvent.buzzReceived &&
          update.packet != null) {
        buzzEngine.processBuzz(update.packet!);
        // Winner handling done in buzz engine stream above.
      }
      _connectedTeams = server.connectedTeams;
    });
  }

  /// Start the competition.
  Future<void> startCompetition(List<TeamModel> teams) async {
    _connectedTeams = teams;
    state = state.copyWith(
      roomState: RoomState.active,
      roundState: RoundState.idle,
      roundNumber: 0,
    );
  }

  /// Open the buzzer for a new round.
  Future<void> openRound() async {
    final roundId = buzzEngine.openRound();
    final newRound = RoundModel(
      id: roundId,
      roomCode: _roomCode,
      roundNumber: state.roundNumber + 1,
      startedAt: DateTime.now(),
    );

    state = state.copyWith(
      currentRound: newRound,
      roundState: RoundState.open,
      roundNumber: state.roundNumber + 1,
      buzzEvents: [],
      clearWinner: true,
    );

    await server.broadcast(PacketModel(
      type: PacketType.roundOpen,
      senderId: 'host',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: 0,
      payload: {'roundId': roundId, 'roundNumber': state.roundNumber},
    ));
    await audio.playOpenRound();
  }

  /// Close the current round without a winner.
  Future<void> closeRound() async {
    buzzEngine.closeRound();
    final closed = state.currentRound?.copyWith(
      endedAt: DateTime.now(),
    );
    final rounds = [...state.rounds];
    if (closed != null) rounds.add(closed);

    state = state.copyWith(
      currentRound: closed,
      rounds: rounds,
      roundState: RoundState.closed,
    );

    await server.broadcast(PacketModel(
      type: PacketType.roundClose,
      senderId: 'host',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: 0,
    ));
  }

  /// Reset the buzzer within the same round.
  Future<void> resetRound() async {
    buzzEngine.reopenBuzz();
    state = state.copyWith(
      roundState: RoundState.open,
      clearWinner: true,
    );

    await server.broadcast(PacketModel(
      type: PacketType.roundReset,
      senderId: 'host',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: 0,
    ));
    await audio.playOpenRound();
  }

  /// Accept the winner's answer.
  Future<void> acceptAnswer() async {
    final updated = state.currentRound?.copyWith(answerAccepted: true);
    final rounds = [...state.rounds];
    if (updated != null) rounds.add(updated);

    state = state.copyWith(
      currentRound: updated,
      rounds: rounds,
      roundState: RoundState.closed,
    );

    await server.broadcast(PacketModel(
      type: PacketType.acceptAnswer,
      senderId: 'host',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: 0,
      payload: {'teamId': state.winner?.id ?? ''},
    ));
  }

  /// Reject the winner's answer and reopen buzz.
  Future<void> rejectAnswer() async {
    await server.broadcast(PacketModel(
      type: PacketType.rejectAnswer,
      senderId: 'host',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: 0,
    ));
    await resetRound();
  }

  /// Reopen buzz manually.
  Future<void> reopenBuzz() async {
    buzzEngine.reopenBuzz();
    state = state.copyWith(
      roundState: RoundState.open,
      clearWinner: true,
    );
    await server.broadcast(PacketModel(
      type: PacketType.reopenBuzz,
      senderId: 'host',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: 0,
    ));
  }

  Future<void> pauseCompetition() async {
    timerEngine.pause();
    state = state.copyWith(isPaused: true);
    await server.broadcast(PacketModel(
      type: PacketType.pause,
      senderId: 'host',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: 0,
    ));
  }

  Future<void> resumeCompetition() async {
    timerEngine.resumeTimer();
    state = state.copyWith(isPaused: false);
    await server.broadcast(PacketModel(
      type: PacketType.resume,
      senderId: 'host',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: 0,
    ));
  }

  Future<StatisticsModel> endCompetition() async {
    buzzEngine.reset();
    timerEngine.stop();
    state = state.copyWith(
      isEnded: true,
      roundState: RoundState.closed,
    );

    await server.broadcast(PacketModel(
      type: PacketType.competitionEnd,
      senderId: 'host',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: 0,
    ));

    // Build statistics.
    final stats = _buildStatistics();
    await storage.saveCompetition(stats);
    return stats;
  }

  StatisticsModel _buildStatistics() {
    final teamStatsMap = <String, TeamStatistics>{};

    for (final team in _connectedTeams) {
      teamStatsMap[team.id] = TeamStatistics(team: team);
    }

    for (final round in state.rounds) {
      if (round.winnerTeamId != null) {
        final ts = teamStatsMap[round.winnerTeamId!];
        if (ts != null) {
          teamStatsMap[round.winnerTeamId!] = ts.copyWith(
            wins: ts.wins + (round.answerAccepted == true ? 1 : 0),
          );
        }
      }
      for (final event in round.buzzEvents) {
        if (!event.isValid || event.isDuplicate) continue;
        final ts = teamStatsMap[event.teamId];
        if (ts == null) continue;
        final newFastest = event.reactionTimeMs != null &&
                (ts.fastestReactionMs == null ||
                    event.reactionTimeMs! < ts.fastestReactionMs!)
            ? event.reactionTimeMs
            : ts.fastestReactionMs;
        teamStatsMap[event.teamId] = ts.copyWith(
          buzzAttempts: ts.buzzAttempts + 1,
          fastestReactionMs: newFastest,
          totalReactionMs: ts.totalReactionMs + (event.reactionTimeMs ?? 0),
          validBuzzCount: ts.validBuzzCount + 1,
        );
      }
    }

    return StatisticsModel(
      roomCode: _roomCode,
      competitionName: _competitionName,
      startedAt: _competitionStartedAt ?? DateTime.now(),
      endedAt: DateTime.now(),
      teamStats: teamStatsMap.values.toList(),
      rounds: state.rounds,
    );
  }

  @override
  void dispose() {
    _winnerSub?.cancel();
    _serverSub?.cancel();
    super.dispose();
  }
}
