import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:casavia/model/notification.dart';

class NotificationService{
    static const String apiUrl = 'http://192.168.1.17:3000/notification';

  Future<NotificationMessage> sendNotificationToPerson(NotificationMessage notif, int personId) async {
    final response = await http.post(
      Uri.parse('$apiUrl/save?person_id=$personId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(notif.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return NotificationMessage.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send notification');
    }
  }
  Future<List<NotificationMessage>> fetchNotificationsByUserId(int userId) async {
    final response = await http.get(Uri.parse('$apiUrl/user/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<NotificationMessage> notifications = body.map((dynamic item) => NotificationMessage.fromJson(item)).toList();
      return notifications;
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> markNotificationAsSeen(int notificationId) async {
    final response = await http.put(Uri.parse('$apiUrl/seen/$notificationId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as seen');
    }
  }

  Future<int> countUnseenNotificationsByUserId(int userId) async {
    final response = await http.get(Uri.parse('$apiUrl/seenfalse/$userId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to count unseen notifications');
    }
  }
}
