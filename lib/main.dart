import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/union_controller.dart';
import 'views/splash_screen.dart';
import 'views/onboarding_screen.dart';
import 'views/auth_screen.dart';
import 'views/home_shell.dart';
import 'views/rider_home_dashboard.dart';
import 'views/rider_profile_screen.dart';
import 'views/payment_gateway_screen.dart';
import 'views/rider_ledger_screen.dart';
import 'views/safety_inspection_screen.dart';
import 'views/stations_screen.dart';
import 'views/executive_analytics_screen.dart';
import 'views/disputes_screen.dart';
import 'views/announcements_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TransitFlowApp());
}

class TransitFlowApp extends StatelessWidget {
  const TransitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => UnionController()),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/auth': (context) => const AuthScreen(),
          '/home': (context) => const HomeShell(),
          '/dashboard': (context) => const RiderHomeDashboard(),
          '/profile': (context) => const RiderProfileScreen(),
          '/payment': (context) => const PaymentGatewayScreen(),
          '/ledger': (context) => const RiderLedgerScreen(),
          '/inspections': (context) => const SafetyInspectionScreen(),
          '/stations': (context) => const StationsScreen(),
          '/analytics': (context) => const ExecutiveAnalyticsScreen(),
          '/disputes': (context) => const DisputesScreen(),
          '/announcements': (context) => const AnnouncementsScreen(),
        },
      ),
    );
  }
}
