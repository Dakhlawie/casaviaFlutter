import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:casavia/model/visitor.dart';
class VisitorService {
  static const String baseUrl = 'http://192.168.1.17:3000/visitor'; 

   Future<void> ajouterVisitor() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.17:3000/visitor/save'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
    
      print('Visitor ajouté avec succès');
    } else {
      
      print('Échec de l\'ajout du visiteur: ${response.statusCode}');
    }
  }
}
