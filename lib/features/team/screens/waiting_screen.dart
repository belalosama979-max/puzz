import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/providers.dart';
import '../../../domain/models/team_model.dart';

class WaitingScreen extends ConsumerWidget {
  const WaitingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamState = ref.watch(teamViewModelProvider);
    final buzzState = ref.watch(buzzViewModelProvider);

    // Navigate to buzz screen when round opens.
    ref.listen(buzzViewModelProvider, (prev, next) {
      if (next.buzzState == BuzzState.open ||
          next.buzzState == BuzzState.winner ||
          next.buzzState == BuzzState.locked) {
        context.go(AppRoutes.buzz);
      }
    });

    // Handle kick.
    ref.listen(teamViewModelProvider, (prev, next) {
      if (next.isKicked && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم طردك من الغرفة')),
        );
        context.go(AppRoutes.roleSelection);
      }
    });

    final isConnected = teamState.isConnected;
    final teams = teamState.connectedTeams;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBackgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                color: AppColors.darkSurface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      teamState.roomCode,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      ArabicStrings.connectedToRoom,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulsing Wi-Fi animation
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: (isConnected
                                ? AppColors.success
                                : AppColors.warning)
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isConnected
                              ? AppColors.success
                              : AppColors.warning,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isConnected
                            ? Icons.wifi_rounded
                            : Icons.wifi_off_rounded,
                        size: 48,
                        color: isConnected
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(
                          end: 1.08,
                          duration: 1200.ms,
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(height: 20),
                    Text(
                      isConnected
                          ? ArabicStrings.youAreConnected
                          : ArabicStrings.reconnecting,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ArabicStrings.waitingForHost,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                    ),
                    const SizedBox(height: 32),

                    // Team name badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(teamState.teamColor).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Color(teamState.teamColor),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        teamState.teamName,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Color(teamState.teamColor),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),

              // Other teams list
              if (teams.isNotEmpty)
                Container(
                  height: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${ArabicStrings.teamsConnected} (${teams.length})',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.darkTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: teams.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (ctx, i) {
                            final t = teams[i];
                            return _TeamAvatar(team: t);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({required this.team});
  final TeamModel team;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: team.colorValue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              team.name.isNotEmpty ? team.name[0] : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 50,
          child: Text(
            team.name,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.darkTextSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
