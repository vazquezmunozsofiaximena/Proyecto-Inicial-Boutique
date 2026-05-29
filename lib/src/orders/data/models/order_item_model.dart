import 'package:myapp/src/products/data/models/product_model.dart';

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});
}
