import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/horoscope_provider.dart';
import 'providers/kundli_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/subscription_provider.dart';
import 'services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize native Push Notifications in background
  PushNotificationService.instance.init();

  final authProvider = AuthProvider();
  final subscriptionProvider = SubscriptionProvider();
  final notificationProvider = NotificationProvider();

  await authProvider.init();
  await subscriptionProvider.init();
  await notificationProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => HoroscopeProvider()),
        ChangeNotifierProvider(create: (_) => KundliProvider()),
        ChangeNotifierProvider.value(value: subscriptionProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
      ],
      child: const AstroZenApp(),
    ),
  );
}

class AstroZenApp extends StatelessWidget {
  const AstroZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AstroZen',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
