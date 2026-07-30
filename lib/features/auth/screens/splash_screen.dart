import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/providers.dart';

/// Splash screen shown at app startup.
/// Initializes storage and navigates to onboarding or role selection.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for auth ViewModel to finish loading.
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final authState = ref.read(authViewModelProvider);
    if (authState.isFirstLaunch) {
      context.go(AppRoutes.onboarding);
    } else {
      context.go(AppRoutes.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBackgroundGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo pulse animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(end: 1.08, duration: 1200.ms, curve: Curves.easeInOut),
              const SizedBox(height: 32),
              Text(
                ArabicStrings.appName,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text(
                ArabicStrings.appTagline,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 600.ms),
              const SizedBox(height: 64),
              const CircularProgressIndicator(color: AppColors.primary)
                  .animate()
                  .fadeIn(delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}
