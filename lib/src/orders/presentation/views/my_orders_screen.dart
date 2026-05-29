import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/auth/data/repository/auth_repository.dart';
import 'package:myapp/src/orders/data/models/order_model.dart';
import 'package:myapp/src/orders/data/repository/order_repository.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart'; // <--- AGREGA ESTA LÍNEA AQUÍ ARRIBA

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = Provider.of<AuthRepository>(context, listen: false);
    final orderRepository = Provider.of<OrderRepository>(context, listen: false);
    final currentUser = authRepository.currentUser;

    return Scaffold(
      // REPLAZA EL APPBAR DE LAS PANTALLAS DE PERFIL, CARRITO Y PEDIDOS CON ESTE CÓDIGO
appBar: AppBar(
  title: const Text(
    'Boutique Elegance', 
    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)
  ),
  backgroundColor: const Color(0xFFC8A2C8), // Color Lila original de tu tienda
  elevation: 2,
  // LEADING añade manualmente el botón de regreso que navega al Home sin romper el historial
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black87),
    onPressed: () => context.go('/'), // Te regresa de golpe a la pantalla principal
  ),
),
      body: currentUser == null
          ? const Center(child: Text('Por favor, inicie sesión para ver sus pedidos.'))
          : StreamBuilder<List<Order>>(
              stream: orderRepository.getOrders(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tienes pedidos todavía.'));
                }

                final orders = snapshot.data!;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) {
                    final order = orders[i];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ExpansionTile(
                        title: Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                        subtitle: Text(
                          'Fecha: ${order.timestamp != null ? DateFormat('dd/MM/yyyy hh:mm a').format(order.timestamp!) : 'Procesando...'}', // Cadena corregida
                        ),
                        children: order.items.map((prod) {
                          return ListTile(
                            title: Text(prod.name),
                            subtitle: Text('Precio: \$${prod.price.toStringAsFixed(2)}'),
                            trailing: Text('x ${prod.quantity}'),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
