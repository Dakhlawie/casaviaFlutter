import 'package:casavia/model/accountClosure.dart';
import 'package:http/http.dart' as http;
import 'dart:core';
import 'dart:convert';

class AccountClosureService {
  final String baseUrl = 'http://192.168.1.17:3000/account_closure';
  Future<AccountClosure> ajouterAccountClosure(
      AccountClosure accountClosure) async {
    final url = Uri.parse('$baseUrl/save');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(accountClosure.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return AccountClosure.fromJson(responseData);
    } else {
      throw Exception('Failed to add account closure');
    }
  }
}
