import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/products/presentation/viewmodels/product_viewmodel.dart';
import 'package:myapp/src/products/data/models/product_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);

    return Scaffold(
      // Barra superior elegante que contiene la navegación nativa oficial de la tienda
      appBar: AppBar(
        title: const Text(
          'Boutique Elegance', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)
        ),
        backgroundColor: const Color(0xFFC8A2C8), // Color Lila distintivo de tu diseño
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black87),
            tooltip: 'Mis Pedidos',
            onPressed: () => context.go('/orders'), // Abre tu MyOrdersScreen a pantalla completa
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black87),
            tooltip: 'Carrito de Compras',
            onPressed: () => context.go('/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black87),
            tooltip: 'Mi Perfil',
            onPressed: () => context.go('/profile'), // Abre tu ProfileScreen a pantalla completa
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: productViewModel.getAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFC8A2C8)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar productos: ${snapshot.error}'),
            );
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No hay productos disponibles en este momento.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,          // 2 productos por fila
              childAspectRatio: 0.58,     // ¡AQUÍ ESTÁ EL CAMBIO! Bajó de 0.68 a 0.58 para estirar la tarjeta hacia abajo
              crossAxisSpacing: 12,       // Espaciado horizontal
              mainAxisSpacing: 12,        // Espaciado vertical
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                clipBehavior: Clip.antiAlias, // Asegura que los bordes redondeados corten el contenido
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- RECUADRO CUADRADO PERFECTO (1:1) PARA LA IMAGEN ---
                    AspectRatio(
                      aspectRatio: 1.0, // Fuerza un formato perfectamente cuadrado
                      child: Container(
                        color: Colors.grey[100], // Fondo gris sutil si la imagen tarda en cargar
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover, // Llena el cuadrado adaptando la prenda sin deformarla
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.broken_image, 
                                  size: 40, 
                                  color: Colors.grey
                                ),
                              )
                            : const Icon(
                                Icons.image, 
                                size: 40, 
                                color: Colors.grey
                              ),
                      ),
                    ),
                    
                    // --- INFORMACIÓN DE LA PRENDA ---
                    Padding(
                      padding: const EdgeInsets.all(10.0), // Un padding más cómodo
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2, // Permite hasta dos líneas para nombres largos sin romperse
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 14,
                              color: Colors.black87
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.purple, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 14
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(), // Empuja el botón perfectamente al fondo aprovechando el nuevo espacio largo
                    
                    // --- BOTÓN ACCIÓN DE VER DETALLES ---
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC8A2C8),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 36), // Un poquito más alto el botón para que sea fácil de presionar
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          ),
                          elevation: 1,
                        ),
                        onPressed: () => context.go('/product/${product.id}'),
                        child: const Text(
                          'Ver Detalles', 
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}