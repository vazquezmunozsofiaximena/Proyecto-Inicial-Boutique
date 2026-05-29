import 'package:flutter/material.dart';
import 'package:myapp/src/auth/data/repository/auth_repository.dart';
import 'package:myapp/src/cart/data/models/cart_item_model.dart';
import 'package:myapp/src/cart/data/repository/cart_repository.dart';
import 'package:myapp/src/products/data/models/product_model.dart';
import 'dart:async';

class CartProvider with ChangeNotifier {
  final CartRepository _cartRepository;
  final AuthRepository _authRepository;
  StreamSubscription? _cartSubscription;
  List<CartItem> _items = [];
  bool _userLoaded = false;

  CartProvider({
    required CartRepository cartRepository,
    required AuthRepository authRepository,
  })  : _cartRepository = cartRepository,
        _authRepository = authRepository {
    _authRepository.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  void _onAuthChanged() {
    if (_authRepository.currentUser != null) {
      if (!_userLoaded) {
        _cartSubscription = _cartRepository
            .getCartItems(_authRepository.currentUser!.uid)
            .listen((items) {
          _items = items;
          notifyListeners();
        });
        _userLoaded = true;
      }
    } else {
      _cartSubscription?.cancel();
      _items = [];
      _userLoaded = false;
      notifyListeners();
    }
  }

  Future<void> addItem(Product product) async {
    if (_authRepository.currentUser == null) return;
    final existingIndex =
        _items.indexWhere((i) => i.productId == product.id);
    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      final updated = existing.copyWith(quantity: existing.quantity + 1);
      await _cartRepository.updateCartItem(
          _authRepository.currentUser!.uid, updated);
    } else {
      final newItem = CartItem(
        id: product.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: 1,
      );
      await _cartRepository.addToCart(
          _authRepository.currentUser!.uid, newItem);
    }
  }

  Future<void> addToCart(CartItem item) async {
    if (_authRepository.currentUser == null) return;
    final existingIndex =
        _items.indexWhere((i) => i.productId == item.productId);
    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      final updated = existing.copyWith(quantity: existing.quantity + 1);
      await _cartRepository.updateCartItem(
          _authRepository.currentUser!.uid, updated);
    } else {
      await _cartRepository.addToCart(
          _authRepository.currentUser!.uid, item);
    }
  }

  Future<void> removeItem(String itemId) async {
    if (_authRepository.currentUser == null) return;
    await _cartRepository.removeFromCart(
        _authRepository.currentUser!.uid, itemId);
  }

  Future<void> removeFromCart(String itemId) => removeItem(itemId);

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (_authRepository.currentUser == null) return;
    final itemIndex = _items.indexWhere((i) => i.id == itemId);
    if (itemIndex != -1) {
      if (quantity > 0) {
        final updated = _items[itemIndex].copyWith(quantity: quantity);
        await _cartRepository.updateCartItem(
            _authRepository.currentUser!.uid, updated);
      } else {
        await removeItem(itemId);
      }
    }
  }

  Future<void> clearCart() async {
    if (_authRepository.currentUser == null) return;
    await _cartRepository.clearCart(_authRepository.currentUser!.uid);
  }

  void updateUser() {
    _userLoaded = false;
    _onAuthChanged();
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    _authRepository.removeListener(_onAuthChanged);
    super.dispose();
  }
}
