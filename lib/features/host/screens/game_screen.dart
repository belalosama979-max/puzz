import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/providers.dart';
import '../../../domain/models/room_model.dart';
import '../../../domain/models/team_model.dart';
import '../widgets/round_controls.dart';
import '../widgets/winner_banner.dart';
import '../widgets/team_card.dart';
import '../widgets/network_status_bar.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameViewModelProvider);
    final hostState = ref.watch(hostViewModelProvider);

    // Trigger confetti when winner is found.
    ref.listen<GameState>(gameViewModelProvider, (prev, next) {
      if (prev?.hasWinner == false && next.hasWinner) {
        _confettiController.play();
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBackgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // AppBar
                  _GameAppBar(
                    roundNumber: gameState.roundNumber,
                    isPaused: gameState.isPaused,
                    onPause: () => ref
                        .read(gameViewModelProvider.notifier)
                        .pauseCompetition(),
                    onResume: () => ref
                        .read(gameViewModelProvider.notifier)
                        .resumeCompetition(),
                    onEnd: () => _confirmEnd(context, ref),
                    onHistory: () => context.push(AppRoutes.history),
                  ),

                  // Network status
                  const NetworkStatusBar(),

                  // Winner banner (when there's a winner)
                  if (gameState.hasWinner)
                    WinnerBanner(
                      winnerTeam: gameState.winner!,
                      reactionMs: gameState.currentRound?.winnerReactionMs,
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),

                  // Round state info
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _RoundStatusChip(
                      roundState: gameState.roundState,
                      isPaused: gameState.isPaused,
                    ),
                  ),

                  // Teams grid
                  Expanded(
                    child: _TeamsGrid(
                      teams: hostState.room?.teams ?? [],
                      winnerId: gameState.winner?.id,
                    ),
                  ),

                  // Round controls
                  RoundControls(
                    gameState: gameState,
                    onOpenRound: () =>
                        ref.read(gameViewModelProvider.notifier).openRound(),
                    onCloseRound: () =>
                        ref.read(gameViewModelProvider.notifier).closeRound(),
                    onResetRound: () =>
                        ref.read(gameViewModelProvider.notifier).resetRound(),
                    onAccept: () =>
                        ref.read(gameViewModelProvider.notifier).acceptAnswer(),
                    onReject: () =>
                        ref.read(gameViewModelProvider.notifier).rejectAnswer(),
                    onReopenBuzz: () =>
                        ref.read(gameViewModelProvider.notifier).reopenBuzz(),
                    onStats: () => context.push(AppRoutes.hostStatistics),
                  ),
                ],
              ),

              // Confetti overlay
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  numberOfParticles: 50,
                  colors: const [
                    AppColors.primary,
                    AppColors.buzzWinner,
                    AppColors.secondary,
                    AppColors.success,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmEnd(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ArabicStrings.endCompetition),
        content: const Text(ArabicStrings.endCompetitionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(ArabicStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(ArabicStrings.endCompetition),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final stats =
          await ref.read(gameViewModelProvider.notifier).endCompetition();
      ref.read(statisticsViewModelProvider.notifier).setCurrentStats(stats);
      if (context.mounted) context.go(AppRoutes.results);
    }
  }
}

class _GameAppBar extends StatelessWidget {
  const _GameAppBar({
    required this.roundNumber,
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
    required this.onHistory,
  });

  final int roundNumber;
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEnd;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: AppColors.darkSurface,
      child: Row(
        children: [
          IconButton(
            onPressed: onEnd,
            icon: const Icon(Icons.stop_circle_outlined),
            color: AppColors.error,
            tooltip: ArabicStrings.endCompetition,
          ),
          IconButton(
            onPressed: isPaused ? onResume : onPause,
            icon: Icon(
              isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            ),
            color: AppColors.warning,
          ),
          IconButton(
            onPressed: onHistory,
            icon: const Icon(Icons.history_rounded),
            color: AppColors.darkTextSecondary,
          ),
          const Spacer(),
          Text(
            roundNumber > 0
                ? '${ArabicStrings.roundNumber} $roundNumber'
                : ArabicStrings.startCompetition,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundStatusChip extends StatelessWidget {
  const _RoundStatusChip({
    required this.roundState,
    required this.isPaused,
  });

  final RoundState roundState;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    if (isPaused) {
      return _chip(ArabicStrings.competitionPaused, AppColors.warning,
          Icons.pause_circle_rounded);
    }
    return switch (roundState) {
      RoundState.idle => _chip(ArabicStrings.waitingForBuzz,
          AppColors.darkTextSecondary, Icons.hourglass_empty_rounded),
      RoundState.open => _chip(ArabicStrings.roundOpen, AppColors.success,
              Icons.radio_button_on_rounded)
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(end: 1.03, duration: 800.ms),
      RoundState.answered => _chip(ArabicStrings.winner, AppColors.buzzWinner,
          Icons.emoji_events_rounded),
      RoundState.closed => _chip(
          ArabicStrings.roundClosed, AppColors.darkTextSecondary, Icons.lock),
    };
  }

  Widget _chip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: color, size: 18),
        ],
      ),
    );
  }
}

class _TeamsGrid extends StatelessWidget {
  const _TeamsGrid({required this.teams, this.winnerId});

  final List<TeamModel> teams;
  final String? winnerId;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: teams.length,
      itemBuilder: (ctx, i) {
        final team = teams[i];
        final isWinner = team.id == winnerId;
        return _TeamGridCard(team: team, isWinner: isWinner);
      },
    );
  }
}

class _TeamGridCard extends StatelessWidget {
  const _TeamGridCard({required this.team, required this.isWinner});

  final TeamModel team;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isWinner
            ? AppColors.buzzWinner.withOpacity(0.15)
            : AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWinner
              ? AppColors.buzzWinner
              : Color(team.color).withOpacity(0.3),
          width: isWinner ? 2 : 1,
        ),
        boxShadow: isWinner
            ? [
                BoxShadow(
                  color: AppColors.buzzWinner.withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isWinner)
              const Icon(Icons.emoji_events_rounded,
                  color: AppColors.buzzWinner, size: 24),
            Text(
              team.name,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isWinner ? AppColors.buzzWinner : Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            _ConnectionDot(state: team.connectionState),
          ],
        ),
      ),
    );
  }
}

class _ConnectionDot extends StatelessWidget {
  const _ConnectionDot({required this.state});
  final TeamConnectionState state;

  @override
  Widget build(BuildContext context) {
    final color = state == TeamConnectionState.connected
        ? AppColors.success
        : AppColors.error;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          state == TeamConnectionState.connected
              ? ArabicStrings.connected
              : ArabicStrings.disconnected,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            color: color,
          ),
        ),
      ],
    );
  }
}
