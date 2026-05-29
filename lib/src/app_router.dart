import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/auth/data/repository/auth_repository.dart';
import 'package:myapp/src/auth/presentation/views/login_view.dart';
import 'package:myapp/src/cart/presentation/views/cart_screen.dart';
import 'package:myapp/src/checkout/presentation/views/checkout_screen.dart';
import 'package:myapp/src/home/presentation/views/home_screen.dart';
import 'package:myapp/src/orders/presentation/views/my_orders_screen.dart';
import 'package:myapp/src/product_detail/presentation/views/product_detail_screen.dart';
import 'package:myapp/src/admin/presentation/views/admin_dashboard_screen.dart';
import 'package:myapp/src/profile/presentation/views/profile_screen.dart'; // Importación agregada

class AppRouter {
  final AuthRepository authRepository;

  AppRouter(this.authRepository);

  late final router = GoRouter(
    refreshListenable: authRepository,
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'product/:id',
            builder: (context, state) => ProductDetailScreen(productId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: 'orders',
            builder: (context, state) => const MyOrdersScreen(),
          ),
          GoRoute(
            path: 'checkout',
            builder: (context, state) => const CheckoutScreen(),
          ),
          GoRoute(
            path: 'profile', // Ruta asignada correctamente
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    redirect: (context, state) {
      if (authRepository.isLoading) return null;

      final isAuthenticated = authRepository.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      final isAdmin = authRepository.isAdmin;

      if (isLoggingIn) {
        return isAdmin ? '/admin' : '/';
      }

      if (state.matchedLocation.startsWith('/admin') && !isAdmin) {
        return '/';
      }

      if (state.matchedLocation == '/' && isAdmin) {
        return '/admin';
      }

      return null;
    },
  );
}