import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screen imports
import 'screens/login_page.dart';
import 'screens/forgot_password_page.dart';
import 'screens/email_verification_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/preferences_page.dart';
import 'screens/display_recommendations_page.dart';
import 'screens/first_time_home_page.dart';
import 'screens/home_page.dart';

Future<void> main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const MyApp());
  } catch (e) {
    print('Error initializing app: $e');
    // You might want to show some error UI here
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xplore',
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Add any other theme configurations here
      ),
      initialRoute: '/login', // Changed from '/' to '/login' for clarity
      routes: {
        '/login': (context) => const LoginPage(),
        '/first-time-home': (context) => const FirstTimeHomePage(),
        '/home': (context) => const HomePage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/email-verification': (context) => const EmailVerificationPage(),
        '/signup': (context) => const SignUpPage(),
        '/preferences': (context) => const PreferencesPage(),
        '/display-recommendations': (context) => const DisplayRecommendationsPage(
              recommendations: [], // Pass an empty list or fetch from backend
              userId: '', // Pass the user ID or fetch from Firebase Auth
            ),
      },
      // Add error handling for unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
      },
    );
  }
}