import 'package:casavia/model/reponse.dart';

class Question {
  final int? id;

  final Reponse? reponse;
  final String content;
  final DateTime dateAsked;

  Question({
    this.id,
    this.reponse,
    required this.content,
    required this.dateAsked,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
   Question q=new  Question(
      id: json['id'],
      reponse:
          json['reponse'] != null ? Reponse.fromJson(json['reponse']) : null,
      content: json['content'],
      dateAsked: DateTime.parse(json['dateAsked']),
    );
    return q;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reponse': reponse != null ? reponse?.toJson() : null,
      'content': content,
      'dateAsked': dateAsked.toIso8601String(),
    };
  }
}
