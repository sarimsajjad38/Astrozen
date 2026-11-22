import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/auth_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/horoscope/horoscope_screen.dart';
import '../../screens/horoscope/horoscope_detail_screen.dart';
import '../../screens/kundli/kundli_screen.dart';
import '../../screens/kundli/kundli_result_screen.dart';
import '../../screens/palm_reading/palm_reading_screen.dart';
import '../../screens/palm_reading/palm_result_screen.dart';
import '../../screens/experts/experts_screen.dart';
import '../../screens/experts/expert_profile_screen.dart';
import '../../screens/experts/expert_chat_screen.dart';
import '../../screens/experts/expert_call_screen.dart';
import '../../screens/kundli/kundli_matching_screen.dart';
import '../../screens/subscription/subscription_screen.dart';
import '../../screens/vastu/vastu_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash',       builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding',   builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/auth',         builder: (context, state) => const AuthScreen()),
      GoRoute(path: '/home',         builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/profile',      builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/horoscope',    builder: (context, state) => const HoroscopeScreen()),
      GoRoute(
        path: '/horoscope/:sign',
        builder: (context, state) => HoroscopeDetailScreen(sign: state.pathParameters['sign']!),
      ),
      GoRoute(path: '/kundli',       builder: (context, state) => const KundliScreen()),
      GoRoute(path: '/kundli/matching', builder: (context, state) => const KundliMatchingScreen()),
      GoRoute(
        path: '/kundli/result',
        builder: (context, state) => KundliResultScreen(data: state.extra as Map<String, dynamic>),
      ),
      GoRoute(path: '/palm-reading', builder: (context, state) => const PalmReadingScreen()),
      GoRoute(
        path: '/palm-reading/result',
        builder: (context, state) => PalmResultScreen(data: state.extra as Map<String, dynamic>),
      ),
      GoRoute(path: '/experts',      builder: (context, state) => const ExpertsScreen()),
      GoRoute(
        path: '/experts/:id',
        builder: (context, state) => ExpertProfileScreen(expertId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/experts/chat/:id',
        builder: (context, state) => ExpertChatScreen(expertId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/experts/call/:id',
        builder: (context, state) => ExpertCallScreen(expertId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/subscribe',    builder: (context, state) => const SubscriptionScreen()),
      GoRoute(path: '/vastu',        builder: (context, state) => const VastuScreen()),
    ],
  );
}
