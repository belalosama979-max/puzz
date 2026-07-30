import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/settings_model.dart';
import '../../../modules/storage/storage_repository.dart';

class AuthState {
  const AuthState({
    this.profile,
    this.isFirstLaunch = true,
    this.isLoading = true,
  });

  final ProfileModel? profile;
  final bool isFirstLaunch;
  final bool isLoading;

  AuthState copyWith({
    ProfileModel? profile,
    bool? isFirstLaunch,
    bool? isLoading,
  }) => AuthState(
        profile: profile ?? this.profile,
        isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
        isLoading: isLoading ?? this.isLoading,
      );
}

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel({required this.storage}) : super(const AuthState()) {
    _initialize();
  }

  final StorageRepository storage;
  final _uuid = const Uuid();

  Future<void> _initialize() async {
    await storage.initialize();
    var profile = storage.loadProfile();
    if (profile == null) {
      profile = ProfileModel(id: _uuid.v4(), isFirstLaunch: true);
      await storage.saveProfile(profile);
    }
    state = state.copyWith(
      profile: profile,
      isFirstLaunch: profile.isFirstLaunch,
      isLoading: false,
    );
  }

  Future<void> completeOnboarding() async {
    final profile = state.profile;
    if (profile == null) return;
    final updated = profile.copyWith(isFirstLaunch: false);
    await storage.saveProfile(updated);
    state = state.copyWith(
      profile: updated,
      isFirstLaunch: false,
    );
  }

  String get deviceId => state.profile?.id ?? _uuid.v4();
}
