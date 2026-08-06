import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/team_model.dart';

/// Animated banner shown on the host's game screen when a winner is determined.
class WinnerBanner extends StatelessWidget {
  const WinnerBanner({
    super.key,
    required this.winnerTeam,
    this.reactionMs,
  });

  final TeamModel winnerTeam;
  final int? reactionMs;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.buzzWinner.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Reaction time
          if (reactionMs != null)
            Column(
              children: [
                Text(
                  '$reactionMs',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'ms',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

          const Spacer(),

          // Winner info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                ArabicStrings.winnerIs,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                winnerTeam.name,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Trophy icon with glow
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 30,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(end: 1.1, duration: 600.ms, curve: Curves.easeInOut),
        ],
      ),
    );
  }
}
