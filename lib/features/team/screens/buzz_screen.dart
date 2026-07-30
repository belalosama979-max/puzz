import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/providers.dart';
import '../viewmodels/buzz_viewmodel.dart';
import '../widgets/buzz_button.dart';
import '../widgets/winner_animation.dart';

class BuzzScreen extends ConsumerStatefulWidget {
  const BuzzScreen({super.key});

  @override
  ConsumerState<BuzzScreen> createState() => _BuzzScreenState();
}

class _BuzzScreenState extends ConsumerState<BuzzScreen> {
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
    final buzzState = ref.watch(buzzViewModelProvider);
    final teamState = ref.watch(teamViewModelProvider);

    // Trigger confetti on win.
    ref.listen(buzzViewModelProvider, (prev, next) {
      if (prev?.buzzState != BuzzState.winner &&
          next.buzzState == BuzzState.winner) {
        _confettiController.play();
      }
      // Navigate when competition ends.
      if (next.buzzState == BuzzState.idle &&
          prev?.buzzState != BuzzState.idle &&
          prev?.buzzState != null) {
        // Round reset – show waiting UI inline.
      }
    });

    // Navigate to waiting when round closes completely.
    ref.listen(teamViewModelProvider, (prev, next) {
      if (next.isKicked) {
        context.go(AppRoutes.roleSelection);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.darkBackground,
                  Color(teamState.teamColor).withOpacity(0.08),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Status bar
                _BuzzStatusBar(
                  buzzState: buzzState,
                  roundNumber: buzzState.roundNumber,
                  teamName: teamState.teamName,
                  teamColor: teamState.teamColor,
                ),

                // Main content
                Expanded(
                  child: buzzState.buzzState == BuzzState.winner ||
                          buzzState.buzzState == BuzzState.locked
                      ? _WinnerSection(
                          buzzState: buzzState,
                          localTeamId: teamState.teamId,
                        )
                      : buzzState.buzzState == BuzzState.paused
                          ? _PausedSection()
                          : const SizedBox(),
                ),

                // The BUZZ BUTTON
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: BuzzButton(
                    buzzState: buzzState.buzzState,
                    teamColor: teamState.teamColor,
                    onBuzz: () =>
                        ref.read(buzzViewModelProvider.notifier).buzz(),
                  ),
                ),
              ],
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 60,
              colors: const [
                AppColors.buzzWinner,
                AppColors.primary,
                AppColors.secondary,
                Colors.pink,
                Colors.green,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuzzStatusBar extends StatelessWidget {
  const _BuzzStatusBar({
    required this.buzzState,
    required this.roundNumber,
    required this.teamName,
    required this.teamColor,
  });

  final BuzzClientState buzzState;
  final int roundNumber;
  final String teamName;
  final int teamColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.darkSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Round number
          Text(
            roundNumber > 0
                ? '${ArabicStrings.roundNumber} $roundNumber'
                : '',
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.darkTextSecondary,
              fontSize: 14,
            ),
          ),
          // Team badge
          Row(
            children: [
              Text(
                teamName,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(teamColor),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WinnerSection extends StatelessWidget {
  const _WinnerSection({
    required this.buzzState,
    required this.localTeamId,
  });

  final BuzzClientState buzzState;
  final String localTeamId;

  @override
  Widget build(BuildContext context) {
    final isWinner = buzzState.buzzState == BuzzState.winner;
    return WinnerAnimationWidget(
      isWinner: isWinner,
      winnerName: buzzState.winnerTeamName,
      winnerColor: buzzState.winnerTeamColor,
      reactionMs: buzzState.winnerReactionMs,
      answerAccepted: buzzState.answerAccepted,
    );
  }
}

class _PausedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pause_circle_filled_rounded,
            size: 80,
            color: AppColors.warning,
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
                end: 1.05,
                duration: 1000.ms,
              ),
          const SizedBox(height: 16),
          Text(
            ArabicStrings.competitionPaused,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
