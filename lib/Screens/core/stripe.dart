import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StripePaymentPage extends StatefulWidget {
  @override
  _StripePaymentPageState createState() => _StripePaymentPageState();
}

class _StripePaymentPageState extends State<StripePaymentPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expMonthController = TextEditingController();
  final TextEditingController _expYearController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Future<void> processPayment() async {
    final String apiUrl = 'http://192.168.1.17:3000/api/stripe/charge';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          'email':"meryem@gmail.com",
          'number': _numberController.text,
          'expMonth': int.parse(_expMonthController.text),
          'expYear': int.parse(_expYearController.text),
          'cvc': _cvcController.text,
          'amount': int.parse(_amountController.text) * 100,
          'currency': "EUR",
        },
      ),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Payment successful: $responseData');
    } else {
      print('Payment failed: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stripe Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _numberController,
              decoration: InputDecoration(labelText: 'Card Number'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expMonthController,
                    decoration: InputDecoration(labelText: 'Exp Month'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _expYearController,
                    decoration: InputDecoration(labelText: 'Exp Year'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            TextField(
              controller: _cvcController,
              decoration: InputDecoration(labelText: 'CVC'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: processPayment,
              child: Text('Make Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
