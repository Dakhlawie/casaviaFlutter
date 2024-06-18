import 'dart:convert';
import 'package:casavia/model/conversation.dart';
import 'package:http/http.dart' as http;

import '../model/note.dart';

class ConversationService {
  final String baseUrl = "http://192.168.1.17:3000/conversation";
  Future<bool> checkConversationExists(int userId, int partnerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/exists?userId=$userId&partnerId=$partnerId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception('Failed to check conversation existence');
    }
  }

  Future<Conversation> findByUserAndPartner(int userId, int partnerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/find?userId=$userId&partnerId=$partnerId'),
    );

    if (response.statusCode == 200) {
      return Conversation.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to find conversation');
    }
  }

  Future<Conversation> addConversation(
      Conversation conversation, int userId, int partnerId) async {
    print("hey: ${jsonEncode(conversation.toJson())}");
    final response = await http.post(
      Uri.parse('$baseUrl/add?userId=$userId&partnerId=$partnerId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(conversation.toJson()),
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      return Conversation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add conversation');
    }
  }

  Future<Message> addMessage(int conversationId, Message message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$conversationId/addMessage'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(message.toJson()),
    );

    if (response.statusCode == 200) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add message');
    }
  }

  Future<List<Conversation>> getConversationsByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Conversation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  Future<void> markMessagesAsSeen(Conversation conversation) async {
    final response = await http.put(
      Uri.parse('$baseUrl/markPartnerAsSeen'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(conversation.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark messages as seen');
    }
  }

  Future<int> countUnseenMessagesByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/countUnseenMessages/$userId'),
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Failed to count unseen messages');
    }
  }
}
