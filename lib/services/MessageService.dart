import 'package:casavia/model/message.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MessageService {
  static const String baseUrl = 'http://192.168.1.17:3000/message';
  Future<Message> sendMessage(Message message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(message.toJson()),
    );

    if (response.statusCode == 200) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<List<Message>> getConversation(int senderId, int recipientId) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/conversation?senderId=$senderId&recipientId=$recipientId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Message.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load conversation');
    }
  }
   Future<List<Message>> findBySender(int senderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/findBySender/$senderId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Message.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }
}
