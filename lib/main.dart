import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/onboarding1_community_screen.dart';
import 'ui/screens/onboarding2_proximity_screen.dart';
import 'ui/screens/onboarding3_action_screen.dart';
import 'ui/screens/signin_register_screen.dart';
import 'ui/screens/otp_verification_screen.dart';
import 'ui/screens/id_verification_screen.dart';
import 'ui/screens/selfie_verification_screen.dart';
import 'ui/screens/home_dashboard_screen.dart';
import 'ui/screens/case_detail_screen.dart';
import 'ui/screens/secure_evidence_camera_screen.dart';
import 'ui/screens/upload_history_screen.dart';
import 'ui/screens/police_chat_screen.dart';
import 'ui/screens/rewards_wallet_screen.dart';
import 'ui/screens/safety_guidelines_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/user_profile_screen.dart';
import 'ui/screens/my_reports_screen.dart';
import 'ui/screens/alerts_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  runApp(const SearchCircleApp());
}

class SearchCircleApp extends StatelessWidget {
  const SearchCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SearchCircle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // ── Initial Route ─────────────────────────────────────────────────
      initialRoute: '/',

      // ── Route Map (will grow with each screen) ────────────────────────
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const Onboarding1CommunityScreen(),
        '/onboarding2': (context) => const Onboarding2ProximityScreen(),
        '/onboarding3': (context) => const Onboarding3ActionScreen(),
        '/signin': (context) => const SignInRegisterScreen(),
        '/otp': (context) => const OtpVerificationScreen(),
        '/id-verification': (context) => const IdVerificationScreen(),
        '/selfie-verification': (context) => const SelfieVerificationScreen(),
        '/home': (context) => const HomeDashboardScreen(),
        '/case-detail': (context) => const CaseDetailScreen(),
        '/report': (context) => const SecureEvidenceCameraScreen(),
        '/upload-history': (context) => const UploadHistoryScreen(),
        '/police-chat': (context) => const PoliceChatScreen(),
        '/rewards': (context) => const RewardsWalletScreen(),
        '/safety-guidelines': (context) => const SafetyGuidelinesScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const UserProfileScreen(),
        '/my-reports': (context) => const MyReportsScreen(),
        '/alerts': (context) => const AlertsScreen(),
      },

      // ── Fallback for undefined routes ─────────────────────────────────
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      ),
    );
  }
}
