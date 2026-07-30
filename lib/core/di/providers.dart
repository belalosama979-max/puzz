import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/networking/host_server.dart';
import '../../modules/networking/team_client.dart';
import '../../modules/networking/discovery_service.dart';
import '../../modules/networking/heartbeat_service.dart';
import '../../modules/networking/reconnect_service.dart';
import '../../modules/buzz/buzz_engine.dart';
import '../../modules/timer/timer_engine.dart';
import '../../modules/storage/hive_storage.dart';
import '../../modules/storage/sqlite_storage.dart';
import '../../modules/storage/storage_repository.dart';
import '../../modules/audio/audio_service.dart';
import '../../modules/audio/vibration_service.dart';
import '../../modules/export/pdf_exporter.dart';
import '../../modules/export/csv_exporter.dart';
import '../../modules/export/json_exporter.dart';
import '../../modules/export/share_service.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../features/host/viewmodels/host_viewmodel.dart';
import '../../features/host/viewmodels/game_viewmodel.dart';
import '../../features/team/viewmodels/team_viewmodel.dart';
import '../../features/team/viewmodels/buzz_viewmodel.dart';
import '../../features/statistics/viewmodels/statistics_viewmodel.dart';
import '../../features/settings/viewmodels/settings_viewmodel.dart';

// ─── Storage ──────────────────────────────────────────────────────────────────

final hiveStorageProvider = Provider<HiveStorage>((ref) {
  return HiveStorage();
});

final sqliteStorageProvider = Provider<SqliteStorage>((ref) {
  return SqliteStorage();
});

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(
    hive: ref.watch(hiveStorageProvider),
    sqlite: ref.watch(sqliteStorageProvider),
  );
});

// ─── Audio / Haptics ──────────────────────────────────────────────────────────

final audioServiceProvider = Provider<AudioService>((ref) {
  final settings = ref.watch(settingsViewModelProvider);
  return AudioService(soundEnabled: settings.soundEnabled);
});

final vibrationServiceProvider = Provider<VibrationService>((ref) {
  final settings = ref.watch(settingsViewModelProvider);
  return VibrationService(vibrationEnabled: settings.vibrationEnabled);
});

// ─── Networking ───────────────────────────────────────────────────────────────

final discoveryServiceProvider = Provider<DiscoveryService>((ref) {
  return DiscoveryService();
});

final heartbeatServiceProvider = Provider<HeartbeatService>((ref) {
  return HeartbeatService();
});

final reconnectServiceProvider = Provider<ReconnectService>((ref) {
  return ReconnectService();
});

final hostServerProvider = Provider<HostServer>((ref) {
  return HostServer(
    heartbeatService: ref.watch(heartbeatServiceProvider),
    discoveryService: ref.watch(discoveryServiceProvider),
  );
});

final teamClientProvider = Provider<TeamClient>((ref) {
  return TeamClient(
    heartbeatService: ref.watch(heartbeatServiceProvider),
    reconnectService: ref.watch(reconnectServiceProvider),
  );
});

// ─── Engines ──────────────────────────────────────────────────────────────────

final buzzEngineProvider = Provider<BuzzEngine>((ref) {
  return BuzzEngine();
});

final timerEngineProvider = Provider<TimerEngine>((ref) {
  return TimerEngine();
});

// ─── Export ───────────────────────────────────────────────────────────────────

final pdfExporterProvider = Provider<PdfExporter>((ref) {
  return PdfExporter();
});

final csvExporterProvider = Provider<CsvExporter>((ref) {
  return CsvExporter();
});

final jsonExporterProvider = Provider<JsonExporter>((ref) {
  return JsonExporter();
});

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService();
});

// ─── ViewModels ───────────────────────────────────────────────────────────────

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    storage: ref.watch(storageRepositoryProvider),
  );
});

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  return SettingsViewModel(
    storage: ref.watch(storageRepositoryProvider),
  );
});

final hostViewModelProvider =
    StateNotifierProvider<HostViewModel, HostState>((ref) {
  return HostViewModel(
    server: ref.watch(hostServerProvider),
    buzzEngine: ref.watch(buzzEngineProvider),
    storage: ref.watch(storageRepositoryProvider),
    audio: ref.watch(audioServiceProvider),
  );
});

final gameViewModelProvider =
    StateNotifierProvider<GameViewModel, GameState>((ref) {
  return GameViewModel(
    server: ref.watch(hostServerProvider),
    buzzEngine: ref.watch(buzzEngineProvider),
    timerEngine: ref.watch(timerEngineProvider),
    audio: ref.watch(audioServiceProvider),
    storage: ref.watch(storageRepositoryProvider),
  );
});

final teamViewModelProvider =
    StateNotifierProvider<TeamViewModel, TeamClientState>((ref) {
  return TeamViewModel(
    client: ref.watch(teamClientProvider),
    storage: ref.watch(storageRepositoryProvider),
  );
});

final buzzViewModelProvider =
    StateNotifierProvider<BuzzViewModel, BuzzClientState>((ref) {
  return BuzzViewModel(
    client: ref.watch(teamClientProvider),
    audio: ref.watch(audioServiceProvider),
    vibration: ref.watch(vibrationServiceProvider),
  );
});

final statisticsViewModelProvider =
    StateNotifierProvider<StatisticsViewModel, StatisticsState>((ref) {
  return StatisticsViewModel(
    storage: ref.watch(storageRepositoryProvider),
  );
});
