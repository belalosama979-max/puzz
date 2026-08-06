import 'package:flutter/material.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/team_model.dart';

/// Card widget displaying a connected team's status in the lobby.
class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.team,
    this.onKick,
  });

  final TeamModel team;
  final VoidCallback? onKick;

  @override
  Widget build(BuildContext context) {
    final isConnected = team.connectionState == TeamConnectionState.connected;
    final teamColor = team.colorValue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: teamColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Kick button
          if (onKick != null)
            IconButton(
              onPressed: onKick,
              icon: const Icon(Icons.person_remove_rounded, size: 20),
              color: AppColors.error,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),

          const SizedBox(width: 12),

          // Ping + Battery
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SignalIcon(quality: team.signalQuality),
              Text(
                team.pingMs > 0 ? '${team.pingMs}ms' : '',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: AppColors.darkTextSecondary,
                ),
              ),
              if (team.batteryLevel >= 0)
                _BatteryIcon(level: team.batteryLevel),
            ],
          ),

          const Spacer(),

          // Avatar circle + name
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                team.name,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _connectionLabel(team.connectionState),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: isConnected
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isConnected ? AppColors.success : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Color avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: teamColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: teamColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                team.name.isNotEmpty ? team.name[0] : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _connectionLabel(TeamConnectionState state) {
    return switch (state) {
      TeamConnectionState.connected => ArabicStrings.connected,
      TeamConnectionState.connecting => ArabicStrings.connecting,
      TeamConnectionState.disconnected => ArabicStrings.disconnected,
      TeamConnectionState.reconnecting => ArabicStrings.reconnecting,
      TeamConnectionState.kicked => 'مطرود',
    };
  }
}

class _SignalIcon extends StatelessWidget {
  const _SignalIcon({required this.quality});
  final SignalQuality quality;

  @override
  Widget build(BuildContext context) {
    final color = switch (quality) {
      SignalQuality.excellent => AppColors.signalExcellent,
      SignalQuality.good => AppColors.signalGood,
      SignalQuality.fair => AppColors.signalFair,
      SignalQuality.poor => AppColors.signalPoor,
      SignalQuality.unknown => AppColors.darkTextDisabled,
    };
    return Icon(
      Icons.signal_cellular_alt_rounded,
      size: 16,
      color: color,
    );
  }
}

class _BatteryIcon extends StatelessWidget {
  const _BatteryIcon({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    final color = level > 50
        ? AppColors.success
        : level > 20
            ? AppColors.warning
            : AppColors.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.battery_std_rounded, size: 12, color: color),
        Text(
          '$level%',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 9,
            color: color,
          ),
        ),
      ],
    );
  }
}
