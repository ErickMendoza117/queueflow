import 'package:queueflow/screens/establishment/register_establishment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:queueflow/services/user_service.dart';
import 'package:queueflow/screens/auth/login_screen.dart';
import 'package:queueflow/screens/auth/registration_screen.dart';
import 'package:queueflow/screens/home_screen.dart';
import 'package:queueflow/screens/customer/establishment_list_screen.dart';
import 'package:queueflow/screens/establishment/establishment_queue_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async operations before runApp
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QueueFlow App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/establishments': (context) => const EstablishmentListScreen(),
        '/register_establishment':
            (context) => const RegisterEstablishmentScreen(),
      },
    );
  }
}
