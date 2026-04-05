import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    // Small delay to show splash screen for MVP
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = context.read<AppAuthProvider>();
    if (authProvider.user == null) {
      await authProvider.signInAnonymously();
    }
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calculate, size: 80, color: theme.primaryColor),
            ),
            const SizedBox(height: 30),
            Text(
              'Math Battle',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: theme.primaryColor,
                letterSpacing: -1.5,
              ),
            ),
            const Text(
              'ARENA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 60),
            CircularProgressIndicator(
              color: theme.primaryColor,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
