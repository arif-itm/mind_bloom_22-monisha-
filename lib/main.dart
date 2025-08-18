import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'front_screen.dart';
import 'login_screen.dart';
import 'main_navigation.dart';
import 'signup_screen.dart';
import 'onboarding_screen.dart';
import 'homepage.dart'; // Make sure this file has `class HomePage`

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MindBloomApp());
}

class MindBloomApp extends StatelessWidget {
  const MindBloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mind Bloom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Helvetica',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const FrontScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/homepage': (context) => const MainNavigation(), // keep only ONE homepage route
      },
    );
  }
}
