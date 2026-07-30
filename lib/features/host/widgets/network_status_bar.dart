import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';

/// A slim bar at the top of host screens showing network/Wi-Fi status.
class NetworkStatusBar extends ConsumerWidget {
  const NetworkStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, this would observe a NetworkStatusProvider.
    // For now, show a placeholder that indicates local Wi-Fi connection.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: AppColors.darkSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_rounded,
            size: 14,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            'Wi-Fi محلي',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
