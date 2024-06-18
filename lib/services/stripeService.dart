import 'package:http/http.dart' as http;
import 'dart:convert';

class StripeService {
  final String baseUrl = "http://192.168.1.17:3000/api/stripe";

  Future<Map<String, dynamic>> createCharge(String number, int expMonth,
      int expYear, String cvc, int amount, String currency) async {
    final url = Uri.parse('$baseUrl/charge');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'number': number,
      'expMonth': expMonth,
      'expYear': expYear,
      'cvc': cvc,
      'amount': amount,
      'currency': currency
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
