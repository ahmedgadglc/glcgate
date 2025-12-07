import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:glcgate/core/animations/page_transitions.dart';
import 'package:glcgate/core/helper/responsive.dart';
import 'package:glcgate/core/theme/app_colors.dart';
import 'package:glcgate/core/widgets/glc_logo.dart';
import 'package:glcgate/core/widgets/animated_glc_logo.dart';
import 'package:glcgate/features/auth/presentation/widgets/animated_button.dart';
import 'package:glcgate/features/auth/presentation/widgets/password_field.dart';
import 'package:glcgate/features/auth/presentation/widgets/username_field.dart';
import 'package:glcgate/features/products/presentation/screens/products_screen.dart';

class LoginFormSection extends StatefulWidget {
  const LoginFormSection({super.key});

  @override
  State<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends State<LoginFormSection> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      // Show error or handle validation
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay (design only - backend integration will be added later)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Navigate to products screen
    Navigator.of(
      context,
    ).pushReplacement(FadePageRoute(child: const ProductsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    if (isDesktop) {
      // Desktop layout: Row with logo on left, form on right
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side - Animated Logo
          Expanded(
            flex: 4,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AnimatedGlcLogo(width: 250),
                  const SizedBox(height: 24),
                  Text(
                    'مرحباً بك في GLC Gate',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Vertical divider
          Container(
            width: 1,
            height: 300,
            color: AppColors.grey200,
            margin: const EdgeInsets.symmetric(horizontal: 32),
          ),

          // Right side - Form Fields
          Expanded(flex: 6, child: _buildFormFields(context)),
        ],
      );
    } else {
      // Mobile/Tablet layout: Vertical with logo at top
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo
          const LogoGLC(width: 120)
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(0.7, 0.7),
                duration: 400.ms,
                curve: Curves.easeOut,
              ),
          const SizedBox(height: 32),
          _buildFormFields(context),
        ],
      );
    }
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
              'تسجيل الدخول',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor.shade800,
              ),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: -0.2, end: 0, duration: 400.ms),
        const SizedBox(height: 8),

        // Subtitle
        Text(
              'مرحباً بك في GLC Gate',
              style: TextStyle(fontSize: 16, color: AppColors.greyDark),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .slideY(begin: -0.2, end: 0, duration: 400.ms),
        const SizedBox(height: 48),

        // Username Input
        UsernameField(
              controller: _usernameController,
              focusNode: _usernameFocusNode,
              // errorText: state.status == AuthStatus.error
              //     ? state.errorMessage
              //     : null,
              onChanged: (value) {
                // context.read<AuthCubit>().clearError();
              },
              onSubmitted: () {
                // Move focus to password field when Enter is pressed
                _passwordFocusNode.requestFocus();
              },
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, duration: 400.ms),
        const SizedBox(height: 24),

        // Password Input
        PasswordField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              onChanged: (value) {
                // context.read<AuthCubit>().clearError();
              },
              onSubmitted: () {
                // Trigger login when Enter is pressed on password field
                if (!_isLoading) {
                  _handleLogin();
                }
              },
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, duration: 400.ms),
        const SizedBox(height: 16),

        // Remember Me Checkbox
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? true;
                });
              },
              activeColor: AppColors.primaryColor,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Text(
              'تذكرني',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.greyDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
        const SizedBox(height: 32),

        // Login Button
        AnimatedButton(
              text: 'تسجيل الدخول',
              icon: Iconsax.login_copy,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleLogin,
            )
            .animate()
            .fadeIn(delay: 700.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, duration: 400.ms),
      ],
    );
  }
}
