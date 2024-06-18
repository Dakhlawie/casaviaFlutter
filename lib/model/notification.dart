import 'package:intl/intl.dart';

enum NotificationType {
  BOOKING,
  CONTACT,
  DELETE,
  QUESTION,
  REVIEW,
  OFFRE,
  MAIL,
  ANNULATION,
  LIKE,
  RESPONSE,
  CONFIRMED,
}

class NotificationMessage {
  final int? notificationId;
  final String title;
  final DateTime date;
  final bool seen;
  final NotificationType type;


  NotificationMessage({
  this.notificationId,
    required this.title,
    required this.date,
    required this.seen,
    required this.type,
  
  });

  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      notificationId: json['notification_id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      seen: json['seen'],
      type: NotificationType.values.firstWhere((e) => e.toString() == 'NotificationType.${json['type']}'),
   
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'title': title,
      'date': DateFormat('yyyy-MM-ddTHH:mm:ss').format(date), 
      'seen': seen,
      'type': type.toString().split('.').last,
      
    };
  }
}
