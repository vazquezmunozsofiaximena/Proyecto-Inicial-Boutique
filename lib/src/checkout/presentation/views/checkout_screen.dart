import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:myapp/src/cart/presentation/provider/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _direccion = '';
  String _metodo = 'Efectivo';
  bool _orderPlaced = false;

  final List<String> _metodosPago = ['Efectivo', 'Tarjeta', 'Transferencia'];

  @override
  Widget build(BuildContext context) {
    final checkoutVM = Provider.of<CheckoutViewModel>(context);
    final cart = Provider.of<CartProvider>(context);

    if (_orderPlaced) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pedido Confirmado')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text('¡Tu pedido fue realizado con éxito!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Volver a la tienda'),
              ),
              TextButton(
                onPressed: () => context.go('/orders'),
                child: const Text('Ver mis pedidos'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Compra')),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tu carrito está vacío.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Ir a la tienda'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Resumen del pedido
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Resumen del pedido',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const Divider(),
                            ...cart.items.map((item) => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Text(
                                            '${item.name} x${item.quantity}')),
                                    Text(
                                        '\$${item.totalPrice.toStringAsFixed(2)}'),
                                  ],
                                )),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text(
                                    '\$${cart.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dirección
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Dirección de entrega',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      onSaved: (value) => _direccion = value ?? '',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'La dirección es requerida' : null,
                    ),
                    const SizedBox(height: 16),

                    // Método de pago
                    DropdownButtonFormField<String>(
                      value: _metodo,
                      decoration: const InputDecoration(
                        labelText: 'Método de pago',
                        prefixIcon: Icon(Icons.payment),
                      ),
                      items: _metodosPago
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _metodo = value ?? 'Efectivo'),
                    ),
                    const SizedBox(height: 24),

                    checkoutVM.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            label: const Text('CONFIRMAR PEDIDO'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                await checkoutVM.placeOrder();
                                if (mounted) {
                                  setState(() => _orderPlaced = true);
                                }
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}