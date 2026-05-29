import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/products/data/repository/product_repository.dart';
import 'package:myapp/src/products/data/models/product_model.dart';
import 'package:myapp/src/cart/presentation/provider/cart_provider.dart';
import 'package:myapp/src/auth/data/repository/auth_repository.dart';
import 'package:go_router/go_router.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final productRepository = Provider.of<ProductRepository>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authRepo = Provider.of<AuthRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Producto')),
      body: StreamBuilder<Product?>(
        stream: productRepository.getProductById(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Producto no encontrado.'));
          }

          final product = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        height: 300,
                        errorBuilder: (c, o, s) => Container(
                          height: 300,
                          color: Colors.pink[50],
                          child: const Icon(Icons.image_not_supported, size: 80),
                        ),
                      )
                    : Container(
                        height: 300,
                        color: Colors.pink[50],
                        child: const Icon(Icons.image_not_supported, size: 80),
                      ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text('\$${product.price.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Theme.of(context).primaryColor)),
                      const SizedBox(height: 8),
                      Text(
                        product.stock > 0
                            ? 'Stock disponible: ${product.stock}'
                            : 'Agotado',
                        style: TextStyle(
                            color: product.stock > 0 ? Colors.green : Colors.red),
                      ),
                      const SizedBox(height: 16),
                      Text(product.description,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_shopping_cart),
                          label: Text(product.stock > 0
                              ? 'Añadir al carrito'
                              : 'Agotado'),
                          onPressed: product.stock <= 0
                              ? null
                              : () {
                                  if (!authRepo.isAuthenticated) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Iniciar sesión'),
                                        content: const Text(
                                            'Debes iniciar sesión para agregar productos al carrito.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              context.go('/login');
                                            },
                                            child: const Text('Iniciar sesión'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    cartProvider.addItem(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '¡"${product.name}" añadido al carrito!'),
                                        duration: const Duration(seconds: 2),
                                        action: SnackBarAction(
                                          label: 'VER CARRITO',
                                          onPressed: () => context.go('/cart'),
                                        ),
                                      ),
                                    );
                                  }
                                },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
