import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/src/cart/data/models/cart_item_model.dart';

class Order {
  final String? id;
  final String userId;
  final double totalAmount;
  final List<CartItem> items;
  final DateTime? timestamp;

  Order({
    this.id,
    required this.userId,
    required this.totalAmount,
    required this.items,
    this.timestamp,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      items: (data['items'] as List<dynamic>? ?? [])
          .map((itemData) {
            final map = itemData as Map<String, dynamic>;
            return CartItem.fromMap(map['id'] ?? '', map);
          })
          .toList(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toMap()).toList(),
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
