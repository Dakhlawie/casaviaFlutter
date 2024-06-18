import 'package:casavia/model/user.dart';
import 'package:casavia/model/person.dart';
import 'package:casavia/model/note.dart';

class Conversation {
  int? id;
  User? user;
  Person? partner;
  List<Message>? messages;

  Conversation({
    this.id,
    this.user,
    this.partner,
    this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    print('Conversation JSON: $json');
    return Conversation(
      id: json['id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      partner:
          json['partner'] != null ? Person.fromJson(json['partner']) : null,
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((messageJson) => Message.fromJson(messageJson))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'partner': partner?.toJson(),
      'messages': messages?.map((message) => message.toJson()).toList(),
    };
  }
}
