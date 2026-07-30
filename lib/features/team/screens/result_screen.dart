import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/providers.dart';

class TeamResultScreen extends ConsumerStatefulWidget {
  const TeamResultScreen({super.key});

  @override
  ConsumerState<TeamResultScreen> createState() => _TeamResultScreenState();
}

class _TeamResultScreenState extends ConsumerState<TeamResultScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamViewModelProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.darkBackgroundGradient),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    size: 100,
                    color: AppColors.buzzWinner,
                  )
                      .animate()
                      .scaleXY(begin: 0, duration: 700.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  Text(
                    ArabicStrings.competitionOver,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.roleSelection),
                    child: const Text(ArabicStrings.newCompetition),
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 50,
              colors: const [
                AppColors.buzzWinner,
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
