import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/providers.dart';
import '../../statistics/viewmodels/statistics_viewmodel.dart';
import '../../../domain/models/statistics_model.dart';
import '../../../domain/models/round_model.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(statisticsViewModelProvider);
    final stats = statsState.currentStats;

    return Scaffold(
      appBar: AppBar(
        title: const Text(ArabicStrings.statistics),
        leading: const BackButton(),
        actions: [
          if (stats != null)
            IconButton(
              onPressed: () => _showExportOptions(context, ref, stats),
              icon: const Icon(Icons.download_rounded),
              tooltip: ArabicStrings.exportResults,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: ArabicStrings.leaderboard),
            Tab(text: ArabicStrings.perRoundStats),
            Tab(text: ArabicStrings.reactionGraph),
          ],
        ),
      ),
      body: stats == null
          ? const Center(child: Text(ArabicStrings.noStatistics))
          : TabBarView(
              controller: _tabController,
              children: [
                _LeaderboardTab(stats: stats),
                _RoundStatsTab(rounds: stats.rounds),
                _ReactionGraphTab(stats: stats),
              ],
            ),
    );
  }

  Future<void> _showExportOptions(
    BuildContext context,
    WidgetRef ref,
    StatisticsModel stats,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ExportBottomSheet(stats: stats),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab({required this.stats});
  final StatisticsModel stats;

  @override
  Widget build(BuildContext context) {
    final lb = stats.leaderboard;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lb.length,
      itemBuilder: (ctx, i) {
        final ts = lb[i];
        return _StatCard(
          rank: i + 1,
          teamName: ts.team.name,
          teamColor: ts.team.color,
          wins: ts.wins,
          buzzAttempts: ts.buzzAttempts,
          fastestMs: ts.fastestReactionMs,
          avgMs: ts.averageReactionMs.toInt(),
          winRate: ts.winRate,
        ).animate().fadeIn(delay: Duration(milliseconds: 80 * i));
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.rank,
    required this.teamName,
    required this.teamColor,
    required this.wins,
    required this.buzzAttempts,
    this.fastestMs,
    required this.avgMs,
    required this.winRate,
  });

  final int rank;
  final String teamName;
  final int teamColor;
  final int wins;
  final int buzzAttempts;
  final int? fastestMs;
  final int avgMs;
  final double winRate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(teamColor).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Color(teamColor),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                teamName,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.darkDivider),
          // Stats grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: ArabicStrings.totalWins,
                value: '$wins',
                icon: Icons.emoji_events_rounded,
                color: AppColors.buzzWinner,
              ),
              _StatItem(
                label: ArabicStrings.totalBuzzAttempts,
                value: '$buzzAttempts',
                icon: Icons.ads_click_rounded,
                color: AppColors.primary,
              ),
              _StatItem(
                label: ArabicStrings.fastestReaction,
                value: fastestMs != null ? '${fastestMs}ms' : '—',
                icon: Icons.bolt_rounded,
                color: AppColors.success,
              ),
              _StatItem(
                label: ArabicStrings.winRate,
                value: '${(winRate * 100).toStringAsFixed(0)}%',
                icon: Icons.percent_rounded,
                color: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.darkTextSecondary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RoundStatsTab extends StatelessWidget {
  const _RoundStatsTab({required this.rounds});
  final List<RoundModel> rounds;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rounds.length,
      itemBuilder: (ctx, i) {
        final r = rounds[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkDivider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.winnerReactionMs != null
                        ? '${r.winnerReactionMs} ms'
                        : '—',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${r.totalBuzzAttempts} ${ArabicStrings.totalBuzzAttempts}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.darkTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${ArabicStrings.roundNumber} ${r.roundNumber}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    r.winnerTeamName ?? ArabicStrings.noWinner,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: r.winnerTeamName != null
                          ? AppColors.buzzWinner
                          : AppColors.darkTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 60 * i));
      },
    );
  }
}

class _ReactionGraphTab extends StatelessWidget {
  const _ReactionGraphTab({required this.stats});
  final StatisticsModel stats;

  @override
  Widget build(BuildContext context) {
    final lb = stats.leaderboard;
    if (lb.isEmpty) {
      return const Center(child: Text(ArabicStrings.noStatistics));
    }

    final maxReaction = lb
        .where((t) => t.fastestReactionMs != null)
        .map((t) => t.fastestReactionMs!)
        .fold(1, (a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          ArabicStrings.fastestReaction,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 16),
        ...lb.map((ts) {
          final ms = ts.fastestReactionMs ?? 0;
          final fraction = maxReaction > 0 ? ms / maxReaction : 0.0;
          return _BarRow(
            teamName: ts.team.name,
            teamColor: ts.team.color,
            ms: ms,
            fraction: fraction,
          ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.3, end: 0);
        }),
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.teamName,
    required this.teamColor,
    required this.ms,
    required this.fraction,
  });

  final String teamName;
  final int teamColor;
  final int ms;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ms > 0 ? '${ms}ms' : '—',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Color(teamColor),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                teamName,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ms > 0 ? fraction.clamp(0.05, 1.0) : 0,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(teamColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExportBottomSheet extends ConsumerWidget {
  const _ExportBottomSheet({required this.stats});
  final StatisticsModel stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ArabicStrings.exportResults,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 20),
          _ExportButton(
            label: ArabicStrings.exportPDF,
            icon: Icons.picture_as_pdf_rounded,
            color: const Color(0xFFD32F2F),
            onTap: () async {
              final path = await ref.read(pdfExporterProvider).export(stats);
              if (path != null && context.mounted) {
                await ref.read(shareServiceProvider).shareFile(
                      path,
                      ArabicStrings.pdfTitle,
                    );
              }
            },
          ),
          const SizedBox(height: 12),
          _ExportButton(
            label: ArabicStrings.exportCSV,
            icon: Icons.table_chart_rounded,
            color: const Color(0xFF388E3C),
            onTap: () async {
              final path = await ref.read(csvExporterProvider).export(stats);
              if (path != null && context.mounted) {
                await ref.read(shareServiceProvider).shareFile(
                      path,
                      stats.competitionName,
                    );
              }
            },
          ),
          const SizedBox(height: 12),
          _ExportButton(
            label: ArabicStrings.exportJSON,
            icon: Icons.code_rounded,
            color: AppColors.primary,
            onTap: () async {
              final path = await ref.read(jsonExporterProvider).export(stats);
              if (path != null && context.mounted) {
                await ref.read(shareServiceProvider).shareFile(
                      path,
                      stats.competitionName,
                    );
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}
