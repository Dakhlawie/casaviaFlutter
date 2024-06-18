import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:casavia/model/contact.dart';

class ContactService {
  static const String apiUrl = 'http://192.168.1.17:3000/contact';

  Future<Contact> ajouterContact(Contact contact) async {
    final response = await http.post(
      Uri.parse('$apiUrl/save'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(contact.toJson()),
    );

    if (response.statusCode == 200) {
      return Contact.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add contact');
    }
  }
 Future<void> sendEmail(String email, String name) async {
    final response = await http.post(
      Uri.parse('$apiUrl/confirmation?email=$email&name=$name'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send email');
    }
  }
}
