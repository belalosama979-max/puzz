import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/settings_model.dart';
import '../../../modules/storage/storage_repository.dart';

class SettingsState {
  const SettingsState({
    this.isDarkMode = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.animationsEnabled = true,
    this.autoReconnect = true,
    this.language = 'ar',
  });

  final bool isDarkMode;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool animationsEnabled;
  final bool autoReconnect;
  final String language;

  SettingsState copyWith({
    bool? isDarkMode,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? animationsEnabled,
    bool? autoReconnect,
    String? language,
  }) => SettingsState(
        isDarkMode: isDarkMode ?? this.isDarkMode,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
        animationsEnabled: animationsEnabled ?? this.animationsEnabled,
        autoReconnect: autoReconnect ?? this.autoReconnect,
        language: language ?? this.language,
      );

  SettingsModel toModel() => SettingsModel(
        isDarkMode: isDarkMode,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        animationsEnabled: animationsEnabled,
        autoReconnect: autoReconnect,
        language: language,
      );

  static SettingsState fromModel(SettingsModel m) => SettingsState(
        isDarkMode: m.isDarkMode,
        soundEnabled: m.soundEnabled,
        vibrationEnabled: m.vibrationEnabled,
        animationsEnabled: m.animationsEnabled,
        autoReconnect: m.autoReconnect,
        language: m.language,
      );
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  SettingsViewModel({required this.storage}) : super(const SettingsState()) {
    _load();
  }

  final StorageRepository storage;

  void _load() {
    final m = storage.loadSettings();
    state = SettingsState.fromModel(m);
  }

  Future<void> setDarkMode(bool value) async {
    state = state.copyWith(isDarkMode: value);
    await _save();
  }

  Future<void> setSound(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await _save();
  }

  Future<void> setVibration(bool value) async {
    state = state.copyWith(vibrationEnabled: value);
    await _save();
  }

  Future<void> setAnimations(bool value) async {
    state = state.copyWith(animationsEnabled: value);
    await _save();
  }

  Future<void> setAutoReconnect(bool value) async {
    state = state.copyWith(autoReconnect: value);
    await _save();
  }

  Future<void> _save() => storage.saveSettings(state.toModel());
}
