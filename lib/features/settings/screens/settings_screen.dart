import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider);
    final vm = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ArabicStrings.settings),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          _SectionHeader(title: ArabicStrings.theme),
          _SettingsTile(
            icon: settings.isDarkMode
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            title: ArabicStrings.darkMode,
            subtitle: settings.isDarkMode
                ? ArabicStrings.darkMode
                : ArabicStrings.lightMode,
            trailing: Switch(
              value: settings.isDarkMode,
              onChanged: vm.setDarkMode,
            ),
          ),

          const SizedBox(height: 16),

          // Sound section
          _SectionHeader(title: ArabicStrings.sound),
          _SettingsTile(
            icon: settings.soundEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            title: ArabicStrings.sound,
            trailing: Switch(
              value: settings.soundEnabled,
              onChanged: vm.setSound,
            ),
          ),
          _SettingsTile(
            icon: settings.vibrationEnabled
                ? Icons.vibration_rounded
                : Icons.phone_android_rounded,
            title: ArabicStrings.vibration,
            trailing: Switch(
              value: settings.vibrationEnabled,
              onChanged: vm.setVibration,
            ),
          ),
          _SettingsTile(
            icon: Icons.animation_rounded,
            title: ArabicStrings.animations,
            trailing: Switch(
              value: settings.animationsEnabled,
              onChanged: vm.setAnimations,
            ),
          ),

          const SizedBox(height: 16),

          // Network section
          _SectionHeader(title: ArabicStrings.networkStatus),
          _SettingsTile(
            icon: Icons.wifi_tethering_rounded,
            title: ArabicStrings.autoReconnect,
            trailing: Switch(
              value: settings.autoReconnect,
              onChanged: vm.setAutoReconnect,
            ),
          ),

          const SizedBox(height: 24),

          // About section
          _SectionHeader(title: ArabicStrings.about),
          _InfoTile(
            icon: Icons.info_outline_rounded,
            title: ArabicStrings.appName,
            value: 'بازماستر 1.0.0',
          ),
          _InfoTile(
            icon: Icons.code_rounded,
            title: 'المطور',
            value: 'BuzzMaster Team',
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
        textAlign: TextAlign.right,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkDivider),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: trailing,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.right,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.right,
              )
            : null,
        trailing: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkDivider),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.right,
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.darkTextSecondary,
            fontSize: 13,
          ),
          textAlign: TextAlign.right,
        ),
        trailing: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }
}
