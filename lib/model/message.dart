import 'package:casavia/model/user.dart';

class Message {
  int? messageId;
  User sender;
  User recipient;
  String? content;
  DateTime timestamp;
  int? hebergementId;

  Message({
    this.messageId,
    required this.sender,
    required this.recipient,
    this.content,
    required this.timestamp,
    this.hebergementId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'],
      sender: User.fromJson(json['sender']),
      recipient: User.fromJson(json['recipient']),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      hebergementId: json['hebergementId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'sender': sender.toJson(),
      'recipient': recipient.toJson(),
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'hebergementId': hebergementId,
    };
  }
}
