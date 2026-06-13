import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/logo.png',
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 96,
                    height: 96,
                    color: AppTheme.primary,
                    child: const Center(child: Icon(Icons.person, color: Colors.white, size: 48)),
                  );
                },
              ),
            ).animate().fade(duration: 500.ms).scale(duration: 500.ms, curve: Curves.easeOut),
            const SizedBox(height: 16),
            Text(
              'Sakshi AI',
              style: GoogleFonts.caveat(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ).animate().fade(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              'Helpful Assistant',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ).animate().fade(delay: 400.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}