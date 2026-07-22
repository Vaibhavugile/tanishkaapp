import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/splash/screens/splash_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Hide Status Bar
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const TanishkaApp());
}

class TanishkaApp extends StatelessWidget {
  const TanishkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tanishka',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',

        scaffoldBackgroundColor: const Color(0xffFFF8F8),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffB24772),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}