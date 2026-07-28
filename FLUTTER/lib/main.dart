import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:impactai/app/routes/app_pages.dart';
import 'package:impactai/base/color_data.dart';
import 'package:impactai/base/restart_controller.dart';
import 'app/notifier/dark_mode.dart';
import 'app/view/discover/CrashDetailPage.dart';
import 'base/my_behaviour.dart';
import 'base/my_custom_scroll_behavior.dart';
import 'firebase_messaging_service.dart';
import 'generated/l10n.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 BG Message: ${message.notification?.title}");
  navigateToLatestCrash();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Subscribe to "crash_alerts" and log the result to the console
  FirebaseMessaging.instance
      .subscribeToTopic('crash_alerts')
      .then((_) => print("Subscribed to crash_alerts"))
      .catchError((e) => print("Failed to subscribe to crash_alerts: $e"));

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Handle notifications when the app is opened from a terminated state
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      navigateToLatestCrash();
    }
  });

  runApp(RestartController(
    child: ChangeNotifierProvider(
      create: (context) => DarkMode(context),
      child: const MyApp(),
    ),
  ));
}

/// Navigates to `CrashDetailPage`, letting it fetch crash data internally
void navigateToLatestCrash() {
  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) => const CrashDetailPage(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var darkThemeProvider = Provider.of<DarkMode>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child!,
        );
      },
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        S.delegate,
      ],
      title: 'Impact AI',
      initialRoute: "/",
      theme: ThemeData(
        scaffoldBackgroundColor: "#FFFFFF".toColor(),
        textTheme: TextTheme(
          titleMedium: TextStyle(color: "#0F172A".toColor()),
          titleSmall: TextStyle(color: "#525E7B".toColor()),
          titleLarge: TextStyle(color: "#000000".toColor()),
        ),
        splashColor: "#E5E5E5".toColor(),
        hoverColor: "#F7F7FF".toColor(),
        cardColor: "#F2F5FF".toColor(),
        primaryColorLight: "#FFFFFF".toColor(),
        dialogBackgroundColor: "#FFFFFF".toColor(),
        focusColor: "#B9C1D3".toColor(),
        hintColor: "#525E7B".toColor(),
        disabledColor: "#525E7B".toColor(),
        canvasColor: "#F7F8FB".toColor(),
        dividerColor: "#D7DDEC".toColor(),
        shadowColor: const Color.fromRGBO(131, 157, 216, 0.12),
        colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: "#0F172A".toColor()),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: "#161E2D".toColor(),
        primaryColorDark: "#161E2D".toColor(),
        hoverColor: "#21F6F7FF".toColor(),
        dialogBackgroundColor: "#283048".toColor(),
        splashColor: "#5E57FF".toColor(),
        focusColor: "#525E7B".toColor(),
        cardColor: "#2D354F".toColor(),
        dividerColor: "#2B354D".toColor(),
        canvasColor: "#525E7B".toColor(),
        hintColor: "#A6ADBE".toColor(),
        disabledColor: "#FFFFFF".toColor(),
        shadowColor: const Color.fromRGBO(0, 0, 0, 0.47),
        textTheme: TextTheme(
          titleMedium: TextStyle(color: "#FFFFFF".toColor()),
          titleSmall: TextStyle(color: "#A6ADBE".toColor()),
          titleLarge: TextStyle(color: "#FFFFFF".toColor()),
        ),
        colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: "#5E57FF".toColor()),
      ),
      themeMode: darkThemeProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
      routes: {
        ...AppPages.routes,
        '/crashDetail': (context) => const CrashDetailPage(),
      },
    );
  }
}