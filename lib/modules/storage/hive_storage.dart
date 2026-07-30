import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/settings_model.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Fast key-value storage backed by Hive.
///
/// Stores settings, user profile, and current session data.
class HiveStorage {
  static const String _settingsKey = 'settings';
  static const String _profileKey = 'profile';

  Box? _settingsBox;
  Box? _profileBox;
  Box? _sessionBox;

  bool get isInitialized => _settingsBox != null;

  /// Initialize Hive and open boxes. Call once at app startup.
  Future<void> initialize() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(AppConstants.hiveBoxSettings);
    _profileBox = await Hive.openBox(AppConstants.hiveBoxProfile);
    _sessionBox = await Hive.openBox(AppConstants.hiveBoxSession);
    _log.d('Hive initialized');
  }

  // ─── Settings ──────────────────────────────────────────────────────────────

  Future<void> saveSettings(SettingsModel settings) async {
    await _settingsBox?.put(_settingsKey, jsonEncode(settings.toJson()));
  }

  SettingsModel loadSettings() {
    final raw = _settingsBox?.get(_settingsKey) as String?;
    if (raw == null) return SettingsModel.defaults;
    try {
      return SettingsModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (e) {
      _log.e('Failed to load settings: $e');
      return SettingsModel.defaults;
    }
  }

  // ─── Profile ───────────────────────────────────────────────────────────────

  Future<void> saveProfile(ProfileModel profile) async {
    await _profileBox?.put(_profileKey, jsonEncode(profile.toJson()));
  }

  ProfileModel? loadProfile() {
    final raw = _profileBox?.get(_profileKey) as String?;
    if (raw == null) return null;
    try {
      return ProfileModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (e) {
      _log.e('Failed to load profile: $e');
      return null;
    }
  }

  // ─── Session ───────────────────────────────────────────────────────────────

  Future<void> setSessionValue(String key, dynamic value) async {
    await _sessionBox?.put(key, value);
  }

  T? getSessionValue<T>(String key) {
    return _sessionBox?.get(key) as T?;
  }

  Future<void> clearSession() async {
    await _sessionBox?.clear();
  }

  Future<void> dispose() async {
    await Hive.close();
  }
}
