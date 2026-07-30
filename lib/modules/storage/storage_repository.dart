import 'package:logger/logger.dart';

import '../../domain/models/settings_model.dart';
import '../../domain/models/statistics_model.dart';
import 'hive_storage.dart';
import 'sqlite_storage.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Unified storage repository combining Hive and SQLite.
///
/// - Fast settings and profile ops → Hive.
/// - Structured competition history → SQLite.
class StorageRepository {
  StorageRepository({
    required this.hive,
    required this.sqlite,
  });

  final HiveStorage hive;
  final SqliteStorage sqlite;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await hive.initialize();
    await sqlite.initialize();
    _initialized = true;
    _log.d('StorageRepository initialized');
  }

  // ─── Settings ──────────────────────────────────────────────────────────────

  SettingsModel loadSettings() => hive.loadSettings();
  Future<void> saveSettings(SettingsModel settings) =>
      hive.saveSettings(settings);

  // ─── Profile ───────────────────────────────────────────────────────────────

  ProfileModel? loadProfile() => hive.loadProfile();
  Future<void> saveProfile(ProfileModel profile) => hive.saveProfile(profile);

  // ─── Competition History ───────────────────────────────────────────────────

  Future<void> saveCompetition(StatisticsModel stats) =>
      sqlite.saveCompetition(stats);

  Future<List<StatisticsModel>> loadAllCompetitions() =>
      sqlite.loadAllCompetitions();

  Future<StatisticsModel?> loadCompetition(String roomCode) =>
      sqlite.loadCompetition(roomCode);

  Future<void> deleteCompetition(String roomCode, DateTime startedAt) =>
      sqlite.deleteCompetition(roomCode, startedAt);

  // ─── Session ───────────────────────────────────────────────────────────────

  Future<void> setSession(String key, dynamic value) =>
      hive.setSessionValue(key, value);

  T? getSession<T>(String key) => hive.getSessionValue<T>(key);

  Future<void> clearSession() => hive.clearSession();

  Future<void> dispose() async {
    await hive.dispose();
    await sqlite.close();
  }
}
