import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentRepository {
  // URL de la Firebase Cloud Function desplegada
  final String _functionUrl = 'https://us-central1-bdcrudboutique.cloudfunctions.net/createStripePaymentIntent';

  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_functionUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear el PaymentIntent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión con el servidor de pagos: $e');
    }
  }
}