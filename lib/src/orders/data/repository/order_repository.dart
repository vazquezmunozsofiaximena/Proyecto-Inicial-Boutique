import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart' hide Order; 
import 'package:myapp/src/orders/data/models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  Future<void> addOrder(Order order) async {
    try {
      await _firestore.collection('orders').add(order.toMap());
    } catch (e, s) {
      developer.log(
        'Error al añadir el pedido',
        name: 'OrderRepository',
        error: e,
        stackTrace: s,
      );
      throw Exception('No se pudo añadir el pedido');
    }
  }

  // SOLUCIÓN AL ÍNDICE: Filtramos por usuario y ordenamos de forma nativa en Flutter
  Stream<List<Order>> getOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          try {
            final list = snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
            
            // Ordena del pedido más reciente al más antiguo sin pedirle nada a Firebase
            list.sort((a, b) {
              if (a.timestamp == null) return 1;
              if (b.timestamp == null) return -1;
              return b.timestamp!.compareTo(a.timestamp!);
            });
            
            return list;
          } catch (e, s) {
            developer.log(
              'Error al procesar los pedidos',
              name: 'OrderRepository',
              error: e,
              stackTrace: s,
            );
            return [];
          }
        });
  }
}