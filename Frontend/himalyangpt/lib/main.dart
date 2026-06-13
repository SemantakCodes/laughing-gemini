import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

// Supabase keys are provided via compile-time environment variables
// (use `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_KEY=...`)
const String _envSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _envSupabaseKey = String.fromEnvironment('SUPABASE_KEY');

late final String globalUserId;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read Supabase keys from environment (compile-time)
  const supabaseUrl = _envSupabaseUrl;
  const supabaseKey = _envSupabaseKey;

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw FlutterError(
      'Missing Supabase configuration. Provide SUPABASE_URL and SUPABASE_KEY via --dart-define.\n'
      'Example:\n'
      'flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co '
      '--dart-define=SUPABASE_KEY=your_public_anon_key'
    );
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  // Initialize SharedPreferences & UUID
  final prefs = await SharedPreferences.getInstance();
  String? storedId = prefs.getString('user_id');
  if (storedId == null) {
    storedId = const Uuid().v4();
    await prefs.setString('user_id', storedId);
  }
  globalUserId = storedId;

  runApp(const SakshiAIApp());
}

class SakshiAIApp extends StatelessWidget {
  const SakshiAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sakshi AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const SplashScreen(),
    );
  }
}
