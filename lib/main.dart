import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/config/app_router.dart';
import 'package:myapp/src/auth/data/repository/auth_repository.dart';
import 'package:myapp/src/cart/data/repository/cart_repository.dart';
import 'package:myapp/src/cart/presentation/provider/cart_provider.dart';
import 'package:myapp/src/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:myapp/src/orders/data/repository/order_repository.dart';
import 'package:myapp/src/products/data/repository/product_repository.dart';
import 'package:myapp/src/products/presentation/viewmodels/product_viewmodel.dart';
import 'package:myapp/src/auth/presentation/viewmodels/login_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthRepository>(
          create: (context) => AuthRepository(
            firebaseAuth: firebaseAuth,
            firestore: firestore,
          ),
        ),
        Provider<ProductRepository>(
          create: (context) => ProductRepository(firestore: firestore),
        ),
        Provider<CartRepository>(
          create: (context) => CartRepository(firestore: firestore),
        ),
        Provider<OrderRepository>(
          create: (context) => OrderRepository(firestore: firestore),
        ),
        ChangeNotifierProvider<ProductViewModel>(
          create: (context) => ProductViewModel(context.read<ProductRepository>()),
        ),
        // Corrección definitiva en la inicialización del LoginViewModel
        ChangeNotifierProxyProvider<AuthRepository, LoginViewModel>(
          create: (context) => LoginViewModel(context.read<AuthRepository>()),
          update: (context, auth, previous) => previous ?? LoginViewModel(auth),
        ),
        ChangeNotifierProxyProvider<AuthRepository, CartProvider>(
          create: (context) => CartProvider(
            authRepository: context.read<AuthRepository>(),
            cartRepository: context.read<CartRepository>(),
          ),
          update: (context, auth, previousCart) {
            final newCart = CartProvider(
              authRepository: auth,
              cartRepository: context.read<CartRepository>(),
            );
            newCart.updateUser();
            return newCart;
          },
        ),
        ChangeNotifierProxyProvider<CartProvider, CheckoutViewModel>(
          create: (context) => CheckoutViewModel(
            context.read<AuthRepository>(),
            context.read<CartProvider>(),
            context.read<OrderRepository>(),
          ),
          update: (context, cart, __) => CheckoutViewModel(
            context.read<AuthRepository>(),
            cart,
            context.read<OrderRepository>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authRepository = context.watch<AuthRepository>();
          final appRouter = AppRouter(authRepository);
          return MaterialApp.router(
            title: 'Boutique App',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFC8A2C8),
                brightness: Brightness.light,
              ),
              primaryColor: const Color(0xFFC8A2C8),
            ),
            routerConfig: appRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}