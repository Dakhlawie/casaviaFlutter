import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

class NewCartePage extends StatefulWidget {
  const NewCartePage({Key? key}) : super(key: key);

  @override
  State<NewCartePage> createState() => _NewCartePageState();
}

class _NewCartePageState extends State<NewCartePage> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _cardholderController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[900]!,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  String _cardTypeFromNumber(String cardNumber) {
    // Simple logic to determine card type from card number
    if (cardNumber.startsWith(RegExp(r'4'))) {
      return 'visa';
    } else if (cardNumber.startsWith(RegExp(r'5[1-5]'))) {
      return 'mastercard';
    } else if (cardNumber.startsWith(RegExp(r'3[47]'))) {
      return 'amex';
    } else {
      return 'unknown';
    }
  }

  Future<void> _makePayment() async {
    final String apiUrl = 'http://192.168.1.17:3000/api/paypal/pay';
    final double total = 100.0;
    final String currency = 'USD';
    final String method = 'paypal';
    final String intent = 'sale';
    final String description = 'Description of payment';
    final String cancelUrl = 'https://www.facebook.com/';
    final String successUrl = 'https://www.instagram.com/';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'total': total.toString(),
        'currency': currency,
        'method': method,
        'intent': intent,
        'description': description,
        'cancelUrl': cancelUrl,
        'successUrl': successUrl,
      },
    );
    Future<void> refundPayment(
        String saleId, double amount, String currency) async {
      final String apiUrl = 'http://192.168.1.17:3000/api/paypal/refund';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'saleId': saleId,
          'amount': "20",
          'currency': "USD",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> refundData = json.decode(response.body);
        print('Refund successful: $refundData');
      } else {
        print('Refund failed: ${response.reasonPhrase}');
      }
    }

    print(response.statusCode);
    if (response.statusCode == 200) {
      final Map<String, dynamic> paymentData = json.decode(response.body);
      print(response.body);
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  }

  final String baseUrl = "http://192.168.1.17:3000/api/stripe";
  Future<Map<String, dynamic>> createCharge() async {
    final url = Uri.parse('$baseUrl/charge');

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'number': '4242424242424242',
      'expMonth': 02,
      'expYear': 2025,
      'cvc': '424',
      'amount': 300,
      'currency': 'usd'
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('hey');
        return {'error': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {},
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    SvgPicture.asset(
                      'assets/payement.svg',
                      height: MediaQuery.of(context).size.height * 0.25,
                    ),
                    SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        text: 'Cardholder ',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        children: <TextSpan>[
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _cardholderController,
                      decoration: InputDecoration(
                        hintText: 'Dakhlawie Meryem',
                        prefixIcon: Icon(Icons.person, color: Colors.blue[900]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.blue[900]!,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        text: 'Card number ',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        children: <TextSpan>[
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: InputDecoration(
                        hintText: '1234 5678 9012 3456',
                        prefixIcon:
                            Icon(Icons.credit_card, color: Colors.blue[900]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.blue[900]!,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'Expiration Date ',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '*',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'MM/YY',
                                  prefixIcon: Icon(Icons.calendar_today,
                                      color: Colors.blue[900]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                          255, 66, 75, 90)!,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'CVC ',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '*',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _cvcController,
                                decoration: InputDecoration(
                                  hintText: '123',
                                  prefixIcon: Icon(Icons.credit_card,
                                      color: Colors.blue[900]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.blue[900]!,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          createCharge();
                        },
                        child: Text(
                          'Use this Card',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          textStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
