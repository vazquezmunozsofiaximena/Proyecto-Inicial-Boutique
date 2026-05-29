import 'package:flutter/material.dart';
import 'package:myapp/src/products/data/models/product_model.dart';
import 'package:myapp/src/products/data/repository/product_repository.dart';

class ProductViewModel with ChangeNotifier {
  final ProductRepository _productRepository;

  ProductViewModel(this._productRepository);

  Stream<List<Product>> getAllProducts() => _productRepository.getProducts();

  Future<void> addProduct(Product product) async {
    await _productRepository.addProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _productRepository.updateProduct(product);
  }

  Future<void> deleteProduct(String productId) async {
    await _productRepository.deleteProduct(productId);
  }

  Stream<Product?> getProductById(String productId) {
    return _productRepository.getProductById(productId);
  }
}
