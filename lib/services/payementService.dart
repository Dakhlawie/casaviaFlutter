import 'dart:convert';
import 'package:casavia/model/payement.dart';
import 'package:http/http.dart' as http;

class PayementService {
  final String apiUrl = "http://192.168.1.17:3000/payement";

  Future<Payment> addPayment(Payment payment, int reservationId) async {
    final url = Uri.parse('$apiUrl/add?id=$reservationId');
    print('Request URL: $url');
    print('Request Body: ${jsonEncode(payment.toJson())}');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(payment.toJson()),
    );

    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    } else {
      print('Failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to add payment');
    }
  }

  final String refundApiUrl = "http://192.168.1.17:3000/api/paypal/refund";

  Future<void> refundPayment(
      String transactionId, double amount, String currency) async {
    final response = await http.post(
      Uri.parse(refundApiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'transactionId': transactionId,
        'amount': amount.toString(),
        'currency': currency,
      }),
    );

    print("***************************");
    print(response.statusCode);
    print("***************************");
    if (response.statusCode == 200) {
      print('Refund successful');
    } else {
      print('Failed to refund: ${response.reasonPhrase}');
    }
  }
}
