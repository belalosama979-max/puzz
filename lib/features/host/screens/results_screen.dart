import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/providers.dart';
import '../../statistics/viewmodels/statistics_viewmodel.dart';
import '../../statistics/screens/statistics_screen.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(statisticsViewModelProvider);
    final stats = statsState.currentStats;
    final leaderboard = stats?.leaderboard ?? [];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.darkBackgroundGradient,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 72,
                        color: AppColors.buzzWinner,
                      )
                          .animate()
                          .scaleXY(begin: 0, duration: 600.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 12),
                      Text(
                        ArabicStrings.finalResults,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ).animate().fadeIn(delay: 400.ms),
                      if (leaderboard.isNotEmpty)
                        Text(
                          '${ArabicStrings.champion2}: ${leaderboard.first.team.name}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.buzzWinner,
                              ),
                        ).animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ),

                // Leaderboard
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: leaderboard.length,
                    itemBuilder: (ctx, i) {
                      final ts = leaderboard[i];
                      return _LeaderboardRow(
                        rank: i + 1,
                        teamName: ts.team.name,
                        teamColor: ts.team.color,
                        wins: ts.wins,
                        fastestMs: ts.fastestReactionMs,
                      )
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: 200 + 100 * i))
                          .slideX(begin: 0.2, end: 0);
                    },
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.push(AppRoutes.hostStatistics),
                        icon: const Icon(Icons.bar_chart_rounded),
                        label: const Text(ArabicStrings.viewStats),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(hostViewModelProvider.notifier)
                              .stopServer();
                          context.go(AppRoutes.roleSelection);
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text(ArabicStrings.newCompetition),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 80,
              colors: const [
                AppColors.primary,
                AppColors.buzzWinner,
                AppColors.secondary,
                AppColors.success,
                Colors.pink,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.teamName,
    required this.teamColor,
    required this.wins,
    this.fastestMs,
  });

  final int rank;
  final String teamName;
  final int teamColor;
  final int wins;
  final int? fastestMs;

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isFirst
            ? AppColors.buzzWinner.withValues(alpha: 0.12)
            : AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFirst ? AppColors.buzzWinner : AppColors.darkDivider,
          width: isFirst ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isFirst ? AppColors.buzzWinner : Color(teamColor),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$wins انتصار',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                ),
              ),
              if (fastestMs != null)
                Text(
                  '$fastestMs ms',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const Spacer(),

          // Name
          Text(
            teamName,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isFirst ? AppColors.buzzWinner : Colors.white,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
