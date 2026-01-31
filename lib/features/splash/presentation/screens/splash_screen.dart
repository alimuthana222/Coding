import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/di/injection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = sl<SharedPreferences>();
    final isFirstTime = prefs.getBool('is_first_time') ?? true;

    if (!mounted) return;

    if (isFirstTime) {
      context.go(AppRouter.onboarding);
    } else {
      // ✅ Go directly to main - no login required
      context.go(AppRouter.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Center(child: _buildLogo()),
              )
                  .animate()
                  .scale(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
              )
                  .fadeIn(duration: const Duration(milliseconds: 400)),

              const SizedBox(height: 32),

              // App Name
              Text(
                context.t('app_name'),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              )
                  .animate(delay: const Duration(milliseconds: 400))
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 12),

              // Slogan
              Text(
                context.t('app_slogan'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              )
                  .animate(delay: const Duration(milliseconds: 600))
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .slideY(begin: 0.3, end: 0),

              const Spacer(flex: 2),

              // Loading Spinner
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              )
                  .animate(delay: const Duration(milliseconds: 800))
                  .fadeIn(duration: const Duration(milliseconds: 600)),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.menu_book_rounded,
          size: 50,
          color: AppColors.primary.withOpacity(0.9),
        ),
        const Positioned(
          top: 8,
          right: 20,
          child: Icon(Icons.lightbulb, size: 24, color: AppColors.secondary),
        ),
      ],
    );
  }
}