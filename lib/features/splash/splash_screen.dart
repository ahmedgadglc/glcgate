import 'package:flutter/material.dart';
import 'package:glcgate/core/animations/page_transitions.dart';
import 'package:glcgate/core/services/storage_service.dart';
import 'package:glcgate/features/auth/presentation/screens/login_screen.dart';
import 'package:glcgate/features/products/presentation/screens/products_screen.dart';
import 'package:glcgate/features/splash/widgets/splash_content_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        FadePageRoute(child: const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SplashContent());
  }
}
