import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/providers.dart';
import '../../../domain/models/team_model.dart';
import '../widgets/team_card.dart';
import '../widgets/network_status_bar.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hostState = ref.watch(hostViewModelProvider);
    final room = hostState.room;
    if (room == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final teams = room.teams;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBackgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _LobbyAppBar(
                roomCode: room.code,
                isLocked: room.isLocked,
                onLockToggle: () {
                  if (room.isLocked) {
                    ref.read(hostViewModelProvider.notifier).unlockRoom();
                  } else {
                    ref.read(hostViewModelProvider.notifier).lockRoom();
                  }
                },
                onSettings: () => context.push(AppRoutes.settings),
              ),

              // Network status bar
              const NetworkStatusBar(),

              // Team count header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${teams.length}/${8}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                    ),
                    Text(
                      ArabicStrings.teamsConnected,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),

              // Teams list
              Expanded(
                child: teams.isEmpty
                    ? _EmptyTeams()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: teams.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final team = teams[i];
                          return TeamCard(
                            team: team,
                            onKick: () => _confirmKick(context, ref, team),
                          ).animate().fadeIn(
                                delay: Duration(milliseconds: 80 * i),
                              );
                        },
                      ),
              ),

              // Start button
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: teams.isNotEmpty
                      ? () async {
                          await ref
                              .read(gameViewModelProvider.notifier)
                              .startCompetition(teams);
                          ref
                              .read(gameViewModelProvider.notifier)
                              .setRoomInfo(room.code, room.competitionName);
                          if (context.mounted) {
                            context.go(AppRoutes.game);
                          }
                        }
                      : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(ArabicStrings.startCompetition),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teams.isNotEmpty
                        ? AppColors.success
                        : AppColors.darkSurfaceVariant,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmKick(
    BuildContext context,
    WidgetRef ref,
    TeamModel team,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ArabicStrings.kickTeam),
        content: Text('${ArabicStrings.kickTeamConfirm}\n${team.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(ArabicStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(ArabicStrings.kickTeam),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(hostViewModelProvider.notifier).kickTeam(team.id);
    }
  }
}

class _LobbyAppBar extends StatelessWidget {
  const _LobbyAppBar({
    required this.roomCode,
    required this.isLocked,
    required this.onLockToggle,
    required this.onSettings,
  });

  final String roomCode;
  final bool isLocked;
  final VoidCallback onLockToggle;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          bottom: BorderSide(color: AppColors.darkDivider),
        ),
      ),
      child: Row(
        children: [
          // Lock toggle
          IconButton(
            onPressed: onLockToggle,
            icon: Icon(
              isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
              color: isLocked ? AppColors.warning : AppColors.success,
            ),
          ),
          IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.darkTextSecondary,
          ),
          const Spacer(),
          // Room code
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ArabicStrings.lobby,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                roomCode,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyTeams extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 72,
            color: AppColors.darkTextDisabled,
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
                end: 1.05,
                duration: 1500.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 16),
          Text(
            ArabicStrings.noTeamsYet,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            ArabicStrings.waitingForTeams,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.darkTextDisabled,
                ),
          ),
        ],
      ),
    );
  }
}
