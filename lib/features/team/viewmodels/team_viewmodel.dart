import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/team_model.dart';
import '../../../modules/networking/team_client.dart';
import '../../../modules/storage/storage_repository.dart';

class TeamClientState {
  const TeamClientState({
    this.connectionState = TeamConnectionState.connecting,
    this.roomCode = '',
    this.teamId = '',
    this.teamName = '',
    this.teamColor = 0xFF6C63FF,
    this.avatar = 'lion',
    this.connectedTeams = const [],
    this.hostAddress = '',
    this.rejectionReason = '',
    this.isKicked = false,
  });

  final TeamConnectionState connectionState;
  final String roomCode;
  final String teamId;
  final String teamName;
  final int teamColor;
  final String avatar;
  final List<TeamModel> connectedTeams;
  final String hostAddress;
  final String rejectionReason;
  final bool isKicked;

  bool get isConnected => connectionState == TeamConnectionState.connected;

  TeamClientState copyWith({
    TeamConnectionState? connectionState,
    String? roomCode,
    String? teamId,
    String? teamName,
    int? teamColor,
    String? avatar,
    List<TeamModel>? connectedTeams,
    String? hostAddress,
    String? rejectionReason,
    bool? isKicked,
  }) => TeamClientState(
        connectionState: connectionState ?? this.connectionState,
        roomCode: roomCode ?? this.roomCode,
        teamId: teamId ?? this.teamId,
        teamName: teamName ?? this.teamName,
        teamColor: teamColor ?? this.teamColor,
        avatar: avatar ?? this.avatar,
        connectedTeams: connectedTeams ?? this.connectedTeams,
        hostAddress: hostAddress ?? this.hostAddress,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        isKicked: isKicked ?? this.isKicked,
      );
}

class TeamViewModel extends StateNotifier<TeamClientState> {
  TeamViewModel({
    required this.client,
    required this.storage,
  }) : super(const TeamClientState()) {
    _subscribeToEvents();
  }

  final TeamClient client;
  final StorageRepository storage;
  StreamSubscription? _sub;

  void _subscribeToEvents() {
    _sub = client.events.listen((update) {
      switch (update.event) {
        case TeamClientEvent.connected:
          state = state.copyWith(
            connectionState: TeamConnectionState.connected,
          );
        case TeamClientEvent.disconnected:
          state = state.copyWith(
            connectionState: TeamConnectionState.reconnecting,
          );
        case TeamClientEvent.rejected:
          final reason = update.packet?.payload['reason'] as String? ?? '';
          state = state.copyWith(
            connectionState: TeamConnectionState.disconnected,
            rejectionReason: reason,
          );
        case TeamClientEvent.kicked:
          state = state.copyWith(
            connectionState: TeamConnectionState.kicked,
            isKicked: true,
          );
        case TeamClientEvent.teamListUpdate:
          final teams = (update.packet?.payload['teams'] as List? ?? [])
              .map((t) => TeamModel.fromJson(t as Map<String, dynamic>))
              .toList();
          state = state.copyWith(connectedTeams: teams);
        default:
          break;
      }
    });
  }

  Future<bool> joinRoom({
    required String localId,
    required String hostAddress,
    required int hostPort,
    required String roomCode,
    required String teamName,
    required int teamColor,
    required String avatar,
  }) async {
    state = state.copyWith(
      teamId: localId,
      teamName: teamName,
      teamColor: teamColor,
      avatar: avatar,
      roomCode: roomCode,
      hostAddress: hostAddress,
      connectionState: TeamConnectionState.connecting,
    );

    final ok = await client.connect(
      localId: localId,
      hostAddress: hostAddress,
      hostPort: hostPort,
      roomCode: roomCode,
      teamName: teamName,
      teamColor: teamColor,
      avatar: avatar,
    );

    // Save last team config to profile.
    final profile = storage.loadProfile();
    if (profile != null) {
      await storage.saveProfile(profile.copyWith(
        lastTeamName: teamName,
        lastTeamColor: teamColor,
        lastAvatar: avatar,
      ));
    }

    return ok;
  }

  Future<void> disconnect() async {
    await client.disconnect();
    state = state.copyWith(
      connectionState: TeamConnectionState.disconnected,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
