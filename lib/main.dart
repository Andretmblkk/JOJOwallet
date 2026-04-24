import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inisialisasi locale data Indonesia (wajib sebelum pakai DateFormat id_ID)
  await initializeDateFormatting('id_ID', null);

  // Status bar: ikon gelap untuk tema terang
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const JOJOdompetApp());
}

class JOJOdompetApp extends StatelessWidget {
  const JOJOdompetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JOJOdompet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
    );
  }
}
