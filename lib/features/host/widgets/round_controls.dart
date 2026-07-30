import 'package:flutter/material.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodels/game_viewmodel.dart';
import '../../../domain/models/room_model.dart';

/// Bottom action bar for the host during the game.
/// Adapts its buttons based on the current [GameState].
class RoundControls extends StatelessWidget {
  const RoundControls({
    super.key,
    required this.gameState,
    required this.onOpenRound,
    required this.onCloseRound,
    required this.onResetRound,
    required this.onAccept,
    required this.onReject,
    required this.onReopenBuzz,
    required this.onStats,
  });

  final GameState gameState;
  final VoidCallback onOpenRound;
  final VoidCallback onCloseRound;
  final VoidCallback onResetRound;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onReopenBuzz;
  final VoidCallback onStats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: AppColors.darkDivider)),
      ),
      child: switch (gameState.roundState) {
        RoundState.idle || RoundState.closed => _IdleControls(
            onOpen: onOpenRound,
            onStats: onStats,
          ),
        RoundState.open => _OpenControls(
            onClose: onCloseRound,
          ),
        RoundState.answered => _AnsweredControls(
            onAccept: onAccept,
            onReject: onReject,
            onReopen: onReopenBuzz,
          ),
      },
    );
  }
}

class _IdleControls extends StatelessWidget {
  const _IdleControls({required this.onOpen, required this.onStats});
  final VoidCallback onOpen;
  final VoidCallback onStats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onStats,
            icon: const Icon(Icons.bar_chart_rounded, size: 18),
            label: const Text(ArabicStrings.statistics),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 50),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(ArabicStrings.openRound),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              minimumSize: const Size(0, 50),
            ),
          ),
        ),
      ],
    );
  }
}

class _OpenControls extends StatelessWidget {
  const _OpenControls({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onClose,
      icon: const Icon(Icons.stop_rounded),
      label: const Text(ArabicStrings.closeRound),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        minimumSize: const Size(double.infinity, 52),
      ),
    );
  }
}

class _AnsweredControls extends StatelessWidget {
  const _AnsweredControls({
    required this.onAccept,
    required this.onReject,
    required this.onReopen,
  });
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close_rounded),
                label: const Text(ArabicStrings.rejectAnswer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  minimumSize: const Size(0, 50),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onAccept,
                icon: const Icon(Icons.check_rounded),
                label: const Text(ArabicStrings.acceptAnswer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  minimumSize: const Size(0, 50),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onReopen,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text(ArabicStrings.reopenBuzz),
        ),
      ],
    );
  }
}
