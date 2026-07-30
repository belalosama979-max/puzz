import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodels/buzz_viewmodel.dart';

/// The large, animated BUZZ button.
///
/// States:
/// - [BuzzState.open] → red glowing, pressable
/// - [BuzzState.sent] → orange, "sent" feedback
/// - [BuzzState.locked] → grey, disabled
/// - [BuzzState.winner] → gold, pulsing
/// - [BuzzState.idle] → dark, waiting
class BuzzButton extends StatefulWidget {
  const BuzzButton({
    super.key,
    required this.buzzState,
    required this.teamColor,
    required this.onBuzz,
  });

  final BuzzState buzzState;
  final int teamColor;
  final VoidCallback onBuzz;

  @override
  State<BuzzButton> createState() => _BuzzButtonState();
}

class _BuzzButtonState extends State<BuzzButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.buzzState == BuzzState.open;
    final isWinner = widget.buzzState == BuzzState.winner;
    final isLocked = widget.buzzState == BuzzState.locked ||
        widget.buzzState == BuzzState.idle;
    final isSent = widget.buzzState == BuzzState.sent;
    final isPaused = widget.buzzState == BuzzState.paused;

    Color buttonColor;
    String label;
    List<Color> glowColors;

    if (isWinner) {
      buttonColor = AppColors.buzzWinner;
      label = ArabicStrings.youWon;
      glowColors = [AppColors.buzzWinner, const Color(0xFFFFAA00)];
    } else if (isEnabled) {
      buttonColor = AppColors.buzzActive;
      label = ArabicStrings.pressTheBuzzer;
      glowColors = [AppColors.buzzGlow, AppColors.buzzActive];
    } else if (isSent) {
      buttonColor = AppColors.warning;
      label = ArabicStrings.buzzSent;
      glowColors = [AppColors.warning, AppColors.warning];
    } else if (isPaused) {
      buttonColor = AppColors.darkTextDisabled;
      label = ArabicStrings.competitionPaused;
      glowColors = [AppColors.darkTextDisabled, AppColors.darkTextDisabled];
    } else {
      buttonColor = AppColors.buzzDisabled;
      label = ArabicStrings.buzzerLocked;
      glowColors = [AppColors.darkTextDisabled, AppColors.darkSurfaceVariant];
    }

    return GestureDetector(
      onTapDown: isEnabled
          ? (_) => _pressController.forward()
          : null,
      onTapUp: isEnabled
          ? (_) {
              _pressController.reverse();
              widget.onBuzz();
            }
          : null,
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring (only when enabled or winner)
              if (isEnabled || isWinner)
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: buttonColor.withOpacity(0.25),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(
                      end: 1.08,
                      duration: 1000.ms,
                      curve: Curves.easeInOut,
                    ),

              // Main button
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isLocked && !isPaused
                        ? [
                            AppColors.darkSurfaceVariant,
                            AppColors.darkSurface,
                          ]
                        : [
                            buttonColor,
                            buttonColor.withOpacity(0.75),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: buttonColor.withOpacity(isEnabled || isWinner ? 0.5 : 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: isEnabled || isWinner
                        ? buttonColor.withOpacity(0.6)
                        : AppColors.darkDivider,
                    width: 3,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isWinner
                          ? Icons.emoji_events_rounded
                          : isEnabled
                              ? Icons.campaign_rounded
                              : isSent
                                  ? Icons.check_circle_rounded
                                  : Icons.lock_rounded,
                      size: 72,
                      color: isLocked && !isPaused
                          ? AppColors.darkTextDisabled
                          : Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isLocked && !isPaused
                              ? AppColors.darkTextDisabled
                              : Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
