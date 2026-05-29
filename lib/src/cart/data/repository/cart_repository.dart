import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/src/cart/data/models/cart_item_model.dart';

class CartRepository {
  final FirebaseFirestore _firestore;

  CartRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  Stream<List<CartItem>> getCartItems(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CartItem.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addToCart(String userId, CartItem item) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(item.id)
        .set(item.toFirestore());
  }

  Future<void> updateCartItem(String userId, CartItem item) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(item.id)
        .update(item.toFirestore());
  }

  Future<void> removeFromCart(String userId, String itemId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(itemId)
        .delete();
  }

  Future<void> clearCart(String userId) async {
    final cart = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();
    for (var doc in cart.docs) {
      await doc.reference.delete();
    }
  }
}
