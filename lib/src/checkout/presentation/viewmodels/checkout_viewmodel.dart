import 'package:flutter/material.dart';
import 'package:myapp/src/auth/data/repository/auth_repository.dart';
import 'package:myapp/src/cart/presentation/provider/cart_provider.dart';
import 'package:myapp/src/orders/data/models/order_model.dart';
import 'package:myapp/src/orders/data/repository/order_repository.dart';

class CheckoutViewModel with ChangeNotifier {
  final AuthRepository _authRepository;
  final CartProvider _cartProvider;
  final OrderRepository _orderRepository;

  /// Orden de parámetros: authRepository, cartProvider, orderRepository
  CheckoutViewModel(this._authRepository, this._cartProvider, this._orderRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> placeOrder() async {
    if (_cartProvider.items.isEmpty) return;

    final currentUser = _authRepository.currentUser;
    if (currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    final newOrder = Order(
      userId: currentUser.uid,
      totalAmount: _cartProvider.totalAmount,
      items: _cartProvider.items,
    );

    try {
      await _orderRepository.addOrder(newOrder);
      await _cartProvider.clearCart();
    } catch (error) {
      debugPrint('Error al realizar el pedido: $error');
    }

    _isLoading = false;
    notifyListeners();
  }
}
