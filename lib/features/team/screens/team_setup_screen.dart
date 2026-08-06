import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/arabic_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/providers.dart';
import '../../../modules/networking/discovery_service.dart';

class TeamSetupScreen extends ConsumerStatefulWidget {
  const TeamSetupScreen({super.key});

  @override
  ConsumerState<TeamSetupScreen> createState() => _TeamSetupScreenState();
}

class _TeamSetupScreenState extends ConsumerState<TeamSetupScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedColorIndex = 0;
  String _selectedAvatar = AppConstants.availableAvatars.first;
  bool _isConnecting = false;

  // Room code passed via navigation.
  String _roomCode = '';

  @override
  void initState() {
    super.initState();
    // Restore last used team name if available.
    final profile = ref.read(storageRepositoryProvider).loadProfile();
    if (profile != null && profile.lastTeamName.isNotEmpty) {
      _nameController.text = profile.lastTeamName;
    }
    // Start listening for hosts on the network.
    ref.read(discoveryServiceProvider).startListening();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is String) {
      _roomCode = extra;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBackgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        color: Colors.white,
                      ),
                      Text(
                        ArabicStrings.teamSetup,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Room code display
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        _roomCode,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.primaryLight,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 28),

                  // Team name
                  TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: ArabicStrings.teamName,
                      hintText: ArabicStrings.teamNameHint,
                      prefixIcon: Icon(Icons.drive_file_rename_outline_rounded),
                    ),
                    maxLength: 20,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return ArabicStrings.teamNameRequired;
                      }
                      if (v.length > 20) return ArabicStrings.teamNameTooLong;
                      return null;
                    },
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 24),

                  // Color selection
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      ArabicStrings.teamColor,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppConstants.teamColorValues.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final color =
                            Color(AppConstants.teamColorValues[i]);
                        final isSelected = i == _selectedColorIndex;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColorIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.5),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 24),

                  // Avatar selection
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      ArabicStrings.teamAvatar,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppConstants.availableAvatars.map((avatar) {
                      final isSelected = avatar == _selectedAvatar;
                      final name = ArabicStrings.avatarNames[avatar] ?? avatar;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAvatar = avatar),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.darkSurfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color:
                                  isSelected ? Colors.white : AppColors.darkTextSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _isConnecting ? null : _connect,
                    child: _isConnecting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(ArabicStrings.joinNow),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isConnecting = true);

    final auth = ref.read(authViewModelProvider);

    // Try to discover the host.
    // In practice, discovery runs in the background and finds the host.
    // For simplicity, we try connecting to discovered hosts.
    // The team enters the room code; we match it against discovered hosts.
    // For now, we prompt for manual IP input via a dialog if auto-discovery fails.
    String? hostAddress = await _discoverHost();

    if (hostAddress == null && mounted) {
      hostAddress = await _showManualIpDialog();
    }

    if (hostAddress == null) {
      setState(() => _isConnecting = false);
      return;
    }

    final ok = await ref.read(teamViewModelProvider.notifier).joinRoom(
          localId: auth.deviceId,
          hostAddress: hostAddress,
          hostPort: AppConstants.hostPort,
          roomCode: _roomCode,
          teamName: _nameController.text.trim(),
          teamColor: AppConstants.teamColorValues[_selectedColorIndex],
          avatar: _selectedAvatar,
        );

    if (!mounted) return;
    setState(() => _isConnecting = false);

    if (ok) {
      ref
          .read(buzzViewModelProvider.notifier)
          .setLocalTeamId(auth.deviceId);
      context.go(AppRoutes.waiting);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ArabicStrings.connectionFailed)),
      );
    }
  }

  Future<String?> _discoverHost() async {
    // Wait up to 3 seconds for a discovery packet.
    try {
      return await ref
          .read(discoveryServiceProvider)
          .onHostDiscovered
          .where((h) => h.roomCode == _roomCode)
          .first
          .timeout(const Duration(seconds: 3))
          .then((h) => h.address);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _showManualIpDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'أدخل عنوان IP للمضيف',
          textDirection: TextDirection.rtl,
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '192.168.x.x'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(ArabicStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text(ArabicStrings.ok),
          ),
        ],
      ),
    );
  }
}
