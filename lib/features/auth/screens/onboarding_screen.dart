import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/arabic_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/providers.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
}

const _pages = [
  _OnboardingPage(
    title: ArabicStrings.onboardingTitle1,
    description: ArabicStrings.onboardingDesc1,
    icon: Icons.campaign_rounded,
    gradient: [AppColors.primary, AppColors.primaryDark],
  ),
  _OnboardingPage(
    title: ArabicStrings.onboardingTitle2,
    description: ArabicStrings.onboardingDesc2,
    icon: Icons.bolt_rounded,
    gradient: [Color(0xFFFF6B35), Color(0xFFFF3D3D)],
  ),
  _OnboardingPage(
    title: ArabicStrings.onboardingTitle3,
    description: ArabicStrings.onboardingDesc3,
    icon: Icons.wifi_rounded,
    gradient: [Color(0xFF00ACC1), Color(0xFF0277BD)],
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.darkBackgroundGradient,
            ),
          ),

          // Page content
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (ctx, index) {
              final page = _pages[index];
              return _OnboardingPageWidget(page: page, index: index);
            },
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primary
                              : AppColors.darkTextDisabled,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  if (_currentPage < _pages.length - 1)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _skip,
                            child: const Text(ArabicStrings.skip),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _next,
                            child: const Text(ArabicStrings.next),
                          ),
                        ),
                      ],
                    )
                  else
                    ElevatedButton(
                      onPressed: _done,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text(ArabicStrings.start),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _skip() => _done();

  Future<void> _done() async {
    await ref.read(authViewModelProvider.notifier).completeOnboarding();
    if (mounted) context.go(AppRoutes.roleSelection);
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  const _OnboardingPageWidget({required this.page, required this.index});

  final _OnboardingPage page;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: page.gradient.first.withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(page.icon, size: 80, color: Colors.white),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 100 * index))
              .scaleXY(begin: 0.8, end: 1, curve: Curves.elasticOut),
          const SizedBox(height: 48),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 200 + 100 * index))
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.darkTextSecondary,
                  height: 1.6,
                ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 350 + 100 * index)),
        ],
      ),
    );
  }
}
