import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/theme/app_colors.dart';

/// Widget shown in the center of the buzz screen after a winner is determined.
///
/// Shows a win celebration for the winning team,
/// and a graceful "you lost" message for others.
class WinnerAnimationWidget extends StatelessWidget {
  const WinnerAnimationWidget({
    super.key,
    required this.isWinner,
    required this.winnerName,
    required this.winnerColor,
    this.reactionMs,
    this.answerAccepted,
  });

  final bool isWinner;
  final String winnerName;
  final int winnerColor;
  final int? reactionMs;
  final bool? answerAccepted; // null=pending, true=accepted, false=rejected

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Win/lose icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isWinner
                  ? AppColors.buzzWinner.withOpacity(0.15)
                  : AppColors.darkSurfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(
                color: isWinner ? AppColors.buzzWinner : AppColors.darkDivider,
                width: 2,
              ),
              boxShadow: isWinner
                  ? [
                      BoxShadow(
                        color: AppColors.buzzWinner.withOpacity(0.35),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isWinner ? Icons.emoji_events_rounded : Icons.close_rounded,
              size: 52,
              color: isWinner ? AppColors.buzzWinner : AppColors.darkTextSecondary,
            ),
          )
              .animate()
              .scaleXY(
                begin: 0,
                end: 1,
                duration: 500.ms,
                curve: Curves.elasticOut,
              )
              .then()
              .animate(
                onPlay: isWinner ? (c) => c.repeat(reverse: true) : null,
              )
              .scaleXY(
                end: isWinner ? 1.06 : 1,
                duration: 800.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 20),

          // Result text
          Text(
            isWinner ? ArabicStrings.youWon : ArabicStrings.youLost,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isWinner ? AppColors.buzzWinner : AppColors.darkTextSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 12),

          // Winner name (shown to losers too)
          if (!isWinner)
            Text(
              '${ArabicStrings.winnerIs}: $winnerName',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: AppColors.darkTextSecondary,
              ),
            ).animate().fadeIn(delay: 300.ms),

          // Reaction time
          if (reactionMs != null && isWinner) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.buzzWinner.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.buzzWinner.withOpacity(0.3)),
              ),
              child: Text(
                '${ArabicStrings.reactionTime}: ${reactionMs}ms',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.buzzWinner,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],

          // Answer state
          if (answerAccepted != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: answerAccepted!
                    ? AppColors.success.withOpacity(0.12)
                    : AppColors.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: answerAccepted! ? AppColors.success : AppColors.error,
                ),
              ),
              child: Text(
                answerAccepted!
                    ? ArabicStrings.acceptAnswer
                    : ArabicStrings.rejectAnswer,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: answerAccepted! ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ],
      ),
    );
  }
}
