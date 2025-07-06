import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/service_providers.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation.dart';
import '../screens/splash_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Show loading while initializing
    if (authState.isLoading) {
      return const SplashScreen();
    }

    // Check if user is authenticated
    if (authState.isAuthenticated) {
      return const MainNavigation();
    } else {
      return const LoginScreen();
    }
  }
}
