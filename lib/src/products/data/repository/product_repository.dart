import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/src/products/data/models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  Future<void> addProduct(Product product) {
    return _firestore.collection('products').add(product.toFirestore());
  }

  Future<void> updateProduct(Product product) {
    return _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toFirestore());
  }

  Future<void> deleteProduct(String productId) {
    return _firestore.collection('products').doc(productId).delete();
  }

  Stream<Product?> getProductById(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Product.fromFirestore(snapshot);
      } else {
        return null;
      }
    });
  }
}
