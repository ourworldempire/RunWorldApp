import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/providers/user_provider.dart';
import 'package:runworld/screens/splash_screen.dart';
import 'package:runworld/screens/onboarding_screen.dart';
import 'package:runworld/screens/signup_screen.dart';
import 'package:runworld/screens/login_screen.dart';
import 'package:runworld/screens/forgot_password_screen.dart';
import 'package:runworld/screens/home_screen.dart';
import 'package:runworld/screens/active_run_screen.dart';
import 'package:runworld/screens/run_summary_screen.dart';
import 'package:runworld/screens/dashboard_screen.dart';
import 'package:runworld/screens/leaderboard_screen.dart';
import 'package:runworld/screens/profile_screen.dart';
import 'package:runworld/screens/friends_screen.dart';
import 'package:runworld/screens/achievements_screen.dart';
import 'package:runworld/screens/challenges_screen.dart';
import 'package:runworld/screens/settings_screen.dart';
import 'package:runworld/screens/notifications_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isOnSplash = state.matchedLocation == '/';
      if (isOnSplash) return null;

      final isOnAuth = ['/onboarding', '/signup', '/login', '/forgot-password']
          .contains(state.matchedLocation);
      final isLoggedIn = ref.read(userProvider) != null;

      if (!isLoggedIn && !isOnAuth) return '/onboarding';
      if (isLoggedIn && isOnAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/',                name: 'splash',          builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding',      name: 'onboarding',      builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/signup',          name: 'signup',          builder: (c, s) => const SignUpScreen()),
      GoRoute(path: '/login',           name: 'login',           builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/forgot-password', name: 'forgotPassword',  builder: (c, s) => const ForgotPasswordScreen()),
      GoRoute(path: '/home',            name: 'home',            builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/run/active',      name: 'activeRun',       builder: (c, s) => const ActiveRunScreen()),
      GoRoute(
        path: '/run/summary',
        name: 'runSummary',
        builder: (c, s) => RunSummaryScreen(params: s.extra),
      ),
      GoRoute(path: '/dashboard',       name: 'dashboard',       builder: (c, s) => const DashboardScreen()),
      GoRoute(path: '/leaderboard',     name: 'leaderboard',     builder: (c, s) => const LeaderboardScreen()),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (c, s) => const ProfileScreen(),
      ),
      GoRoute(path: '/friends',         name: 'friends',         builder: (c, s) => const FriendsScreen()),
      GoRoute(path: '/achievements',    name: 'achievements',    builder: (c, s) => const AchievementsScreen()),
      GoRoute(path: '/challenges',      name: 'challenges',      builder: (c, s) => const ChallengesScreen()),
      GoRoute(path: '/settings',        name: 'settings',        builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/notifications',   name: 'notifications',   builder: (c, s) => const NotificationsScreen()),
    ],
  );
});
