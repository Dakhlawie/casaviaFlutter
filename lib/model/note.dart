import 'package:casavia/model/user.dart';

class Message {
  int? messageId;
  int senderId;
  String? content;
  String role;
 
  bool seen;

  Message({
    this.messageId,
    required this.senderId,
    this.content,
    required this.role,
 
    this.seen = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'],
      senderId: json['senderId'],
      content: json['content'],
      role: json['role'],
     
      seen: json['seen'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'content': content,
      'role': role,
    
      'seen': seen,
    };
  }
}
