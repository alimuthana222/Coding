import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/main_screen.dart';

class AppRouter {
  AppRouter._();

  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Login
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(),
          child: const LoginScreen(),
        ),
      ),

      // Register
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(),
          child: const RegisterScreen(),
        ),
      ),

      // Main (Home with Bottom Navigation)
      GoRoute(
        path: main,
        name: 'main',
        builder: (context, state) => const MainScreen(),
      ),
    ],
  );
}