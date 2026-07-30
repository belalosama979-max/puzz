import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/providers.dart';
import '../../../domain/models/statistics_model.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statisticsViewModelProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsViewModelProvider);
    final formatter = DateFormat(ArabicStrings.dateTimeFormat);

    return Scaffold(
      appBar: AppBar(title: const Text(ArabicStrings.competitionHistory)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        size: 72,
                        color: AppColors.darkTextDisabled,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        ArabicStrings.noHistory,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.history.length,
                  itemBuilder: (ctx, i) {
                    final s = state.history[i];
                    return _HistoryCard(
                      stats: s,
                      dateStr: formatter.format(s.startedAt),
                      onDelete: () => _confirmDelete(ctx, ref, s),
                    ).animate().fadeIn(delay: Duration(milliseconds: 60 * i));
                  },
                ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    StatisticsModel stats,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ArabicStrings.delete),
        content: Text('${ArabicStrings.delete} "${stats.competitionName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(ArabicStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(ArabicStrings.delete),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref
          .read(statisticsViewModelProvider.notifier)
          .deleteCompetition(stats);
    }
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.stats,
    required this.dateStr,
    required this.onDelete,
  });

  final StatisticsModel stats;
  final String dateStr;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final champion = stats.leaderboard.isNotEmpty
        ? stats.leaderboard.first.team.name
        : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkDivider),
      ),
      child: Row(
        children: [
          // Delete button
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.error,
          ),

          const Spacer(),

          // Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stats.competitionName,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    champion,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.buzzWinner,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.emoji_events_rounded,
                      color: AppColors.buzzWinner, size: 14),
                ],
              ),
              Text(
                '${stats.totalRounds} ${ArabicStrings.totalRounds}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
