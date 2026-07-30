import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/host/screens/create_room_screen.dart';
import '../../features/host/screens/lobby_screen.dart';
import '../../features/host/screens/game_screen.dart';
import '../../features/host/screens/results_screen.dart';
import '../../features/host/screens/statistics_screen.dart';
import '../../features/host/screens/history_screen.dart';
import '../../features/team/screens/join_room_screen.dart';
import '../../features/team/screens/team_setup_screen.dart';
import '../../features/team/screens/waiting_screen.dart';
import '../../features/team/screens/buzz_screen.dart';
import '../../features/team/screens/result_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

/// Route names used throughout the app.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';

  // Host routes
  static const String createRoom = '/host/create-room';
  static const String lobby = '/host/lobby';
  static const String game = '/host/game';
  static const String results = '/host/results';
  static const String hostStatistics = '/host/statistics';
  static const String history = '/host/history';

  // Team routes
  static const String joinRoom = '/team/join';
  static const String teamSetup = '/team/setup';
  static const String waiting = '/team/waiting';
  static const String buzz = '/team/buzz';
  static const String teamResult = '/team/result';

  // Shared
  static const String settings = '/settings';
}

/// GoRouter configuration for BuzzMaster.
/// Applies smooth RTL-compatible page transitions.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (ctx, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const RoleSelectionScreen(),
        ),
      ),

      // ── Host routes ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.createRoom,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const CreateRoomScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.lobby,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const LobbyScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.game,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const GameScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.results,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const ResultsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.hostStatistics,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const StatisticsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.history,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const HistoryScreen(),
        ),
      ),

      // ── Team routes ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.joinRoom,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const JoinRoomScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.teamSetup,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const TeamSetupScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.waiting,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const WaitingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.buzz,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const BuzzScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.teamResult,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const TeamResultScreen(),
        ),
      ),

      // ── Settings ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (ctx, state) => _buildPage(
          state,
          const SettingsScreen(),
        ),
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(
        child: Text('الصفحة غير موجودة: ${state.error}'),
      ),
    ),
  );
});

/// Builds a custom page with a smooth fade + slide transition.
CustomTransitionPage<void> _buildPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
      const begin = Offset(0.05, 0);
      const end = Offset.zero;
      const curve = Curves.easeInOutCubic;
      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}
