import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/statistics_model.dart';
import '../../../modules/storage/storage_repository.dart';

class StatisticsState {
  const StatisticsState({
    this.currentStats,
    this.history = const [],
    this.isLoading = false,
  });

  final StatisticsModel? currentStats;
  final List<StatisticsModel> history;
  final bool isLoading;

  StatisticsState copyWith({
    StatisticsModel? currentStats,
    List<StatisticsModel>? history,
    bool? isLoading,
  }) => StatisticsState(
        currentStats: currentStats ?? this.currentStats,
        history: history ?? this.history,
        isLoading: isLoading ?? this.isLoading,
      );
}

class StatisticsViewModel extends StateNotifier<StatisticsState> {
  StatisticsViewModel({required this.storage}) : super(const StatisticsState());

  final StorageRepository storage;

  void setCurrentStats(StatisticsModel stats) {
    state = state.copyWith(currentStats: stats);
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    final history = await storage.loadAllCompetitions();
    state = state.copyWith(history: history, isLoading: false);
  }

  Future<void> deleteCompetition(StatisticsModel stats) async {
    await storage.deleteCompetition(stats.roomCode, stats.startedAt);
    await loadHistory();
  }
}
