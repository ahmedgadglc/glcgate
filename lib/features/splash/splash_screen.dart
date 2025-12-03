import 'package:flutter/material.dart';
import 'package:glcgate/core/theme/app_colors.dart';
import 'package:glcgate/features/products/presentation/screens/products_screen.dart';
import 'package:glcgate/features/splash/widgets/splash_content_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: Future.delayed(Duration(seconds: 2)).then((value) {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProductsScreen()),
            );
          }
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashContent();
          } else {
            return Center(
              child: Text(
                'Error initializing app',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            );
          }
        },
      ),
    );
  }
}
