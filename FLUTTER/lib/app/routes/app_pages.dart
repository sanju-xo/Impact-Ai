import 'package:flutter/material.dart';
import 'package:impactai/app/routes/app_routes.dart';
import 'package:impactai/app/view/support/chat_support_screen.dart';
import 'package:impactai/app/view/support/call_support_screen.dart';
import 'package:impactai/app/view/home/home_screen.dart';
import 'package:impactai/app/view/intro.dart';
import 'package:impactai/app/view/login/change_password_screen.dart';
import 'package:impactai/app/view/login/login_screen.dart';
import 'package:impactai/app/view/login/verify_code_screen.dart';
import 'package:impactai/app/view/profile/edit_profile_screen.dart';
import 'package:impactai/app/view/profile/edit_location_screen.dart';
import 'package:impactai/app/view/splash_screen.dart';
import 'package:impactai/app/view/discover/CrashDetailPage.dart';

class AppPages {
  static const initialRoute = Routes.homeRoute;

  static Map<String, WidgetBuilder> routes = {
    Routes.homeRoute: (context) => const SplashScreen(),
    Routes.homeScreenRoute: (context) => const HomeScreen(),
    Routes.introRoute: (context) => const IntroView(),
    Routes.loginRoute: (context) => const LoginScreen(),
    Routes.verifyCodeRoute: (context) => const VerifyCodeScreen(),
    Routes.forgotPassRoute: (context) => const ForgotPasswordScreen(),
    Routes.editProfileScreenRoute: (context) => const EditProfileScreen(),
    Routes.editLocationScreenRoute: (context) => const EditLocationScreen(),
    Routes.chatSupportRoute: (context) => const ChatSupportScreen(),
    Routes.callSupportRoute: (context) => const CallSupportScreen(),

    // No need for arguments; CrashDetailPage handles data fetching
    Routes.crashDetailRoute: (context) => const CrashDetailPage(),
  };
}