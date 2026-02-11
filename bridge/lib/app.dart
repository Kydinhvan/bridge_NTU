import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'models/match_result.dart';

// Onboarding
import 'features/onboarding/screens/splash_screen.dart';
import 'features/onboarding/screens/role_selection_screen.dart';
import 'features/onboarding/screens/wellbeing_baseline_screen.dart';
import 'features/onboarding/seeker_onboarding/screens/seeker_chat_screen.dart';
import 'features/onboarding/helper_onboarding/screens/helper_chat_screen.dart';

// Seeker flow
import 'features/seeker/screens/seeker_home_screen.dart';
import 'features/seeker/screens/vent_screen.dart';
import 'features/seeker/screens/safety_check_screen.dart';
import 'features/seeker/screens/processing_screen.dart';
import 'features/seeker/screens/match_reveal_screen.dart';
import 'features/seeker/screens/chat_screen.dart';
import 'features/seeker/screens/impact_dashboard_screen.dart';

// Helper flow
import 'features/helper/screens/helper_home_screen.dart';
import 'features/helper/screens/active_chat_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Onboarding ──────────────────────────────────────────────────────────
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/role-selection', builder: (_, __) => const RoleSelectionScreen()),
    GoRoute(
      path: '/wellbeing-baseline/:role',
      builder: (_, state) => WellbeingBaselineScreen(
        role: state.pathParameters['role'] ?? 'seeker',
      ),
    ),
    GoRoute(path: '/onboarding/seeker-chat', builder: (_, __) => const SeekerChatScreen()),
    GoRoute(path: '/onboarding/helper-chat', builder: (_, __) => const HelperChatScreen()),

    // ── Seeker flow ──────────────────────────────────────────────────────────
    GoRoute(path: '/seeker/home', builder: (_, __) => const SeekerHomeScreen()),
    GoRoute(path: '/seeker/vent', builder: (_, __) => const VentScreen()),
    GoRoute(path: '/seeker/safety-check', builder: (_, __) => const SafetyCheckScreen()),
    GoRoute(
      path: '/seeker/processing',
      builder: (_, state) => ProcessingScreen(
        transcript: state.extra as String?,
      ),
    ),
    GoRoute(
      path: '/seeker/match-reveal',
      builder: (_, state) => MatchRevealScreen(
        match: state.extra as MatchResult?,
      ),
    ),
    GoRoute(path: '/seeker/chat', builder: (_, __) => const ChatScreen()),
    GoRoute(path: '/seeker/impact', builder: (_, __) => const ImpactDashboardScreen()),

    // ── Helper flow ──────────────────────────────────────────────────────────
    GoRoute(path: '/helper/home', builder: (_, __) => const HelperHomeScreen()),
    GoRoute(path: '/helper/request', builder: (_, __) => const ActiveChatScreen()),
    GoRoute(path: '/helper/chat', builder: (_, __) => const ActiveChatScreen()),
  ],
);

class BridgeApp extends StatelessWidget {
  const BridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bridge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: _router,
    );
  }
}
