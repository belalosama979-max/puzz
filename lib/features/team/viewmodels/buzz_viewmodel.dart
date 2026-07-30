import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modules/networking/team_client.dart';
import '../../../modules/audio/audio_service.dart';
import '../../../modules/audio/vibration_service.dart';

enum BuzzState {
  idle,       // Waiting for round to open
  open,       // Round is open – can buzz
  sent,       // Buzz was sent
  locked,     // Someone else won
  winner,     // This team won!
  paused,     // Competition paused
}

class BuzzClientState {
  const BuzzClientState({
    this.buzzState = BuzzState.idle,
    this.roundId = '',
    this.roundNumber = 0,
    this.winnerTeamId = '',
    this.winnerTeamName = '',
    this.winnerReactionMs,
    this.winnerTeamColor = 0xFF6C63FF,
    this.reactionMs,
    this.answerAccepted,
  });

  final BuzzState buzzState;
  final String roundId;
  final int roundNumber;
  final String winnerTeamId;
  final String winnerTeamName;
  final int? winnerReactionMs;
  final int winnerTeamColor;
  final int? reactionMs;
  final bool? answerAccepted; // null=pending, true=accepted, false=rejected

  bool get isBuzzEnabled => buzzState == BuzzState.open;
  bool get isWinner => buzzState == BuzzState.winner;
  bool get isLocked => buzzState == BuzzState.locked;

  BuzzClientState copyWith({
    BuzzState? buzzState,
    String? roundId,
    int? roundNumber,
    String? winnerTeamId,
    String? winnerTeamName,
    int? winnerReactionMs,
    int? winnerTeamColor,
    int? reactionMs,
    bool? answerAccepted,
  }) => BuzzClientState(
        buzzState: buzzState ?? this.buzzState,
        roundId: roundId ?? this.roundId,
        roundNumber: roundNumber ?? this.roundNumber,
        winnerTeamId: winnerTeamId ?? this.winnerTeamId,
        winnerTeamName: winnerTeamName ?? this.winnerTeamName,
        winnerReactionMs: winnerReactionMs ?? this.winnerReactionMs,
        winnerTeamColor: winnerTeamColor ?? this.winnerTeamColor,
        reactionMs: reactionMs ?? this.reactionMs,
        answerAccepted: answerAccepted ?? this.answerAccepted,
      );
}

class BuzzViewModel extends StateNotifier<BuzzClientState> {
  BuzzViewModel({
    required this.client,
    required this.audio,
    required this.vibration,
  }) : super(const BuzzClientState()) {
    _subscribeToEvents();
  }

  final TeamClient client;
  final AudioService audio;
  final VibrationService vibration;

  StreamSubscription? _sub;
  DateTime? _roundOpenedAt;
  String _localTeamId = '';

  void setLocalTeamId(String id) => _localTeamId = id;

  void _subscribeToEvents() {
    _sub = client.events.listen((update) async {
      switch (update.event) {
        case TeamClientEvent.roundOpen:
          _roundOpenedAt = DateTime.now();
          final roundId = update.packet?.payload['roundId'] as String? ?? '';
          final roundNum = update.packet?.payload['roundNumber'] as int? ?? 0;
          state = state.copyWith(
            buzzState: BuzzState.open,
            roundId: roundId,
            roundNumber: roundNum,
            reactionMs: null,
          );
          await audio.playOpenRound();
          await vibration.buzzTap();

        case TeamClientEvent.roundClose:
        case TeamClientEvent.roundReset:
          state = state.copyWith(buzzState: BuzzState.idle);

        case TeamClientEvent.winner:
          final winnerId =
              update.packet?.payload['teamId'] as String? ?? '';
          final winnerName =
              update.packet?.payload['teamName'] as String? ?? '';
          final reactionMs =
              update.packet?.payload['reactionTimeMs'] as int?;
          final winnerColor =
              update.packet?.payload['teamColor'] as int? ?? 0xFF6C63FF;

          final isMe = winnerId == _localTeamId;

          state = state.copyWith(
            buzzState: isMe ? BuzzState.winner : BuzzState.locked,
            winnerTeamId: winnerId,
            winnerTeamName: winnerName,
            winnerReactionMs: reactionMs,
            winnerTeamColor: winnerColor,
          );

          if (isMe) {
            await audio.playWinner();
            await vibration.winPattern();
          } else {
            await vibration.losePattern();
          }

        case TeamClientEvent.lock:
          if (state.buzzState == BuzzState.open) {
            state = state.copyWith(buzzState: BuzzState.locked);
          }

        case TeamClientEvent.unlock:
        case TeamClientEvent.reopenBuzz:
          state = state.copyWith(
            buzzState: BuzzState.open,
            winnerTeamId: '',
            winnerTeamName: '',
          );

        case TeamClientEvent.acceptAnswer:
          state = state.copyWith(answerAccepted: true);

        case TeamClientEvent.rejectAnswer:
          state = state.copyWith(
            answerAccepted: false,
            buzzState: BuzzState.open,
          );

        case TeamClientEvent.pause:
          state = state.copyWith(buzzState: BuzzState.paused);

        case TeamClientEvent.resume:
          state = state.copyWith(buzzState: BuzzState.idle);

        default:
          break;
      }
    });
  }

  /// Send the buzz to the host.
  Future<void> buzz() async {
    if (!state.isBuzzEnabled) {
      await vibration.lockedPattern();
      return;
    }

    final reactionMs = _roundOpenedAt != null
        ? DateTime.now().difference(_roundOpenedAt!).inMilliseconds
        : null;

    state = state.copyWith(
      buzzState: BuzzState.sent,
      reactionMs: reactionMs,
    );

    await client.sendBuzz(roundId: state.roundId);
    await audio.playBuzz();
    await vibration.buzzTap();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
