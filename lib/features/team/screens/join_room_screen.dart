import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/arabic_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showQrScanner = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBackgroundGradient),
        child: SafeArea(
          child: _showQrScanner ? _buildQrScanner() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
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
                  ArabicStrings.joinRoom,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 48),

            // Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF3D3D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3D3D).withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.groups_rounded, size: 56, color: Colors.white),
              ),
            ).animate().fadeIn().scaleXY(begin: 0.8, curve: Curves.elasticOut),
            const SizedBox(height: 40),

            // Code input
            TextFormField(
              controller: _codeController,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo',
                letterSpacing: 6,
              ),
              decoration: const InputDecoration(
                hintText: 'XXXXXX',
                hintStyle: TextStyle(
                  color: AppColors.darkTextDisabled,
                  fontSize: 28,
                  letterSpacing: 6,
                  fontFamily: 'Cairo',
                ),
                labelText: ArabicStrings.enterRoomCode,
              ),
              maxLength: AppConstants.roomCodeLength,
              validator: (v) {
                if (v == null || v.length != AppConstants.roomCodeLength) {
                  return ArabicStrings.invalidCode;
                }
                return null;
              },
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _proceed,
              child: const Text(ArabicStrings.joinNow),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 20),

            // Divider with OR text
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.darkDivider)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    ArabicStrings.orScanQR,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.darkTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.darkDivider)),
              ],
            ),
            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: () => setState(() => _showQrScanner = true),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text(ArabicStrings.scanQR),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQrScanner() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _showQrScanner = false),
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
              ),
              const Spacer(),
              const Text(
                ArabicStrings.scanQR,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: MobileScanner(
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                final value = barcode.rawValue;
                if (value != null) {
                  // QR format: "ip:roomCode"
                  final parts = value.split(':');
                  if (parts.length >= 2) {
                    final roomCode = parts.last;
                    _codeController.text = roomCode;
                    setState(() => _showQrScanner = false);
                    _proceed();
                  }
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _proceed() {
    if (!_formKey.currentState!.validate()) return;
    // Store room code and navigate to team setup.
    context.go(
      AppRoutes.teamSetup,
      extra: _codeController.text.trim().toUpperCase(),
    );
  }
}
