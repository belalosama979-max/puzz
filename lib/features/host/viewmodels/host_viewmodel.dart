import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/models/room_model.dart';
import '../../../domain/models/team_model.dart';
import '../../../domain/models/packet_model.dart';
import '../../../modules/networking/host_server.dart';
import '../../../modules/networking/discovery_service.dart';
import '../../../modules/buzz/buzz_engine.dart';
import '../../../modules/storage/storage_repository.dart';
import '../../../modules/audio/audio_service.dart';

class HostState {
  const HostState({
    this.room,
    this.isLoading = false,
    this.error,
    this.localIp = '',
    this.isServerRunning = false,
  });

  final RoomModel? room;
  final bool isLoading;
  final String? error;
  final String localIp;
  final bool isServerRunning;

  bool get hasRoom => room != null;

  HostState copyWith({
    RoomModel? room,
    bool? isLoading,
    String? error,
    String? localIp,
    bool? isServerRunning,
  }) => HostState(
        room: room ?? this.room,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        localIp: localIp ?? this.localIp,
        isServerRunning: isServerRunning ?? this.isServerRunning,
      );
}

class HostViewModel extends StateNotifier<HostState> {
  HostViewModel({
    required this.server,
    required this.buzzEngine,
    required this.storage,
    required this.audio,
  }) : super(const HostState());

  final HostServer server;
  final BuzzEngine buzzEngine;
  final StorageRepository storage;
  final AudioService audio;
  final _uuid = const Uuid();

  StreamSubscription? _serverSub;

  String _deviceId = '';

  void setDeviceId(String id) => _deviceId = id;

  /// Generate a random 6-character room code.
  String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    return List.generate(
      AppConstants.roomCodeLength,
      (_) => chars[rnd.nextInt(chars.length)],
    ).join();
  }

  /// Create a new room and start the host server.
  Future<void> createRoom(String competitionName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final code = generateRoomCode();
      final room = RoomModel(
        code: code,
        hostId: _deviceId,
        competitionName: competitionName,
        createdAt: DateTime.now(),
      );

      await server.start(
        localId: _deviceId,
        roomCode: code,
        competitionName: competitionName,
      );

      // Get local IP for QR code display.
      final ip = await DiscoveryService().getLocalIpAddress() ?? '';

      state = state.copyWith(
        room: room,
        isLoading: false,
        isServerRunning: true,
        localIp: ip,
      );

      _subscribeToServerEvents();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void _subscribeToServerEvents() {
    _serverSub?.cancel();
    _serverSub = server.events.listen((update) {
      switch (update.event) {
        case HostServerEvent.teamJoined:
        case HostServerEvent.teamDisconnected:
          _refreshTeams();
          audio.playJoin();
        case HostServerEvent.batteryUpdate:
          _refreshTeams();
        case HostServerEvent.buzzReceived:
          // Handled by GameViewModel.
          break;
      }
    });
  }

  void _refreshTeams() {
    final teams = server.connectedTeams;
    final current = state.room;
    if (current == null) return;
    state = state.copyWith(
      room: current.copyWith(teams: teams),
    );
  }

  Future<void> kickTeam(String teamId) async {
    await server.kickTeam(teamId);
    _refreshTeams();
  }

  void lockRoom() {
    server.lockRoom();
    final room = state.room;
    if (room == null) return;
    state = state.copyWith(room: room.copyWith(state: RoomState.locked));
  }

  void unlockRoom() {
    server.unlockRoom();
    final room = state.room;
    if (room == null) return;
    state = state.copyWith(room: room.copyWith(state: RoomState.waiting));
  }

  Future<void> stopServer() async {
    _serverSub?.cancel();
    await server.stop();
    state = const HostState();
  }

  @override
  void dispose() {
    _serverSub?.cancel();
    super.dispose();
  }
}
