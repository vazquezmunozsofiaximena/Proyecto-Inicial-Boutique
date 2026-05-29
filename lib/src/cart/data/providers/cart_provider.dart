import 'package:flutter/foundation.dart';
import 'package:myapp/src/auth/data/repository/auth_repository.dart';
import 'package:myapp/src/products/data/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() => {
    'productId': product.id,
    'quantity': quantity,
    'price': product.price, 
    'name': product.name,
    'imageUrl': product.imageUrl
  };
}

class CartProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, CartItem> _items = {};
  bool _isLoading = false;

  CartProvider(this._authRepository) {
    _authRepository.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  Map<String, CartItem> get items => {..._items};
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  double get totalAmount => _items.values.fold(0.0, (currentSum, item) => currentSum + item.totalPrice);

  void _onAuthChanged() {
    if (_authRepository.currentUser != null) {
      _loadCart();
    } else {
      _items.clear();
      notifyListeners();
    }
  }
  
  DocumentReference get _cartRef => _firestore.collection('carts').doc(_authRepository.currentUser!.uid);

  Future<void> _loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final cartSnapshot = await _cartRef.get();
      if (cartSnapshot.exists && (cartSnapshot.data() as Map).containsKey('items')) {
        final cartData = cartSnapshot.data()! as Map<String, dynamic>;
        final itemsData = cartData['items'] as Map<String, dynamic>;
        final productIds = itemsData.keys.toList();
        
        if (productIds.isEmpty) {
          _items = {};
        } else {
           final productsSnapshot = await _firestore.collection('products').where(FieldPath.documentId, whereIn: productIds).get();
           final Map<String, Product> productsMap = { for (var doc in productsSnapshot.docs) doc.id: Product.fromFirestore(doc) };

            final Map<String, CartItem> loadedItems = {};
            itemsData.forEach((productId, itemData) {
                if(productsMap.containsKey(productId)){
                   final product = productsMap[productId]!;
                   loadedItems[productId] = CartItem(product: product, quantity: itemData['quantity'] as int);
                }
            });
            _items = loadedItems;
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(Product product) async {
    if (_items.containsKey(product.id)) {
      _items.update(product.id, (existing) => CartItem(product: existing.product, quantity: existing.quantity + 1));
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    _items.remove(productId);
    await _saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    if (newQuantity <= 0) {
      removeItem(productId);
    } else {
      _items.update(productId, (existing) => CartItem(product: existing.product, quantity: newQuantity));
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> clear() async {
    _items.clear();
    await _saveCart();
    notifyListeners();
  }

  Future<void> _saveCart() async {
     if (_authRepository.currentUser == null) return;
     final itemsToSave = { for (var item in _items.values) item.product.id : item.toMap() };
     await _cartRef.set({'items': itemsToSave, 'lastUpdated': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }
  
  @override
  void dispose() {
    _authRepository.removeListener(_onAuthChanged);
    super.dispose();
  }
}
