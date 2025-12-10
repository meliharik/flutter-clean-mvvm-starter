import 'package:flutter/material.dart';
import 'package:flutter_clean_mvvm_starter/core/router/route_names.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter_clean_mvvm_starter/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// GoRouter configuration provider
///
/// WHY RIVERPOD PROVIDER FOR ROUTER:
/// 1. Can listen to auth state changes
/// 2. Router automatically rebuilds when auth changes
/// 3. Can inject dependencies into router
///
/// WHY GOROUTER:
/// 1. Declarative routing (define all routes in one place)
/// 2. Type-safe navigation
/// 3. Deep linking support
/// 4. Redirection logic (auth guards)
/// 5. Nested navigation
/// 6. Web URL support
final goRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state to trigger router rebuilds
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,

    /// Redirect logic - Critical for authentication flow
    ///
    /// FLOW:
    /// 1. User navigates to any route
    /// 2. redirect() is called BEFORE building the page
    /// 3. Based on auth state, return new path or null
    /// 4. null = allow navigation, String = redirect to that path
    ///
    /// STATES:
    /// - Initial/Loading: Show splash (check auth)
    /// - Unauthenticated: Redirect to login (unless already there)
    /// - Authenticated: Allow access to protected routes
    redirect: (context, state) {
      final isOnSplash = state.matchedLocation == RouteNames.splash;
      final isOnLogin = state.matchedLocation == RouteNames.login;

      return authState.when(
        // Still checking auth, show splash
        initial: () => isOnSplash ? null : RouteNames.splash,
        loading: () => isOnSplash ? null : RouteNames.splash,

        // Not logged in, redirect to login
        unauthenticated: () => isOnLogin ? null : RouteNames.login,

        // Logged in, allow navigation (or redirect to home if on login)
        authenticated: (_) {
          if (isOnSplash || isOnLogin) {
            return RouteNames.home;
          }
          return null; // Allow navigation to requested page
        },

        // Error during auth, show login
        error: (_) => isOnLogin ? null : RouteNames.login,
      );
    },

    /// Route definitions
    routes: [
      // Splash screen - shown while checking auth
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login screen
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Home screen (protected)
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],

    /// Error page (404, etc.)
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
