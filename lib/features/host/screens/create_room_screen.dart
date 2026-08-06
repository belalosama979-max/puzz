import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/providers.dart';
import '../../host/viewmodels/host_viewmodel.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final _nameController = TextEditingController(text: 'مسابقة بازماستر');
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authViewModelProvider);
    ref.read(hostViewModelProvider.notifier).setDeviceId(auth.deviceId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostViewModelProvider);

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
                  // App bar row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        color: Colors.white,
                      ),
                      Text(
                        ArabicStrings.createRoom,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (!state.isServerRunning) ...[
                    // Competition name field
                    TextFormField(
                      controller: _nameController,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: ArabicStrings.competitionName,
                        prefixIcon: Icon(Icons.emoji_events_rounded),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? ArabicStrings.teamNameRequired
                          : null,
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 32),

                    ElevatedButton.icon(
                      onPressed: state.isLoading ? null : _createRoom,
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_circle_outline_rounded),
                      label: Text(state.isLoading
                          ? ArabicStrings.loading
                          : ArabicStrings.createRoom),
                    ).animate().fadeIn(delay: 300.ms),

                    if (state.error != null) ...[
                      const SizedBox(height: 16),
                      _ErrorCard(message: state.error!),
                    ],
                  ] else ...[
                    // Room created – show code and QR
                    _RoomCodeDisplay(
                      code: state.room!.code,
                      competitionName: state.room!.competitionName,
                      hostAddress: state.localIp,
                    ).animate().fadeIn(duration: 500.ms).scaleXY(begin: 0.9),
                    const SizedBox(height: 24),

                    // QR Code
                    _QRCodeCard(
                      data:
                          '${state.localIp}:${state.room!.code}',
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 24),

                    // Action buttons
                    ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutes.lobby),
                      icon: const Icon(Icons.groups_rounded),
                      label: const Text(ArabicStrings.lobby),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: state.room!.code),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(ArabicStrings.codeCopied),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text(ArabicStrings.copyCode),
                    ).animate().fadeIn(delay: 500.ms),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(hostViewModelProvider.notifier)
        .createRoom(_nameController.text.trim());
  }
}

class _RoomCodeDisplay extends StatelessWidget {
  const _RoomCodeDisplay({
    required this.code,
    required this.competitionName,
    required this.hostAddress,
  });
  final String code;
  final String competitionName;
  final String hostAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            competitionName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            code,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              fontFamily: 'Cairo',
              letterSpacing: 8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hostAddress.isNotEmpty ? hostAddress : '',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

class _QRCodeCard extends StatelessWidget {
  const _QRCodeCard({required this.data});
  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            ArabicStrings.showQR,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.darkBackground,
            ),
          ),
          const SizedBox(height: 16),
          QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
