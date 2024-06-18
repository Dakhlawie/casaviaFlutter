import 'package:casavia/model/question.dart';

class Reponse {
  final int id;
 
  final String content;

  Reponse({
    required this.id,
   
    required this.content,
  });

  factory Reponse.fromJson(Map<String, dynamic> json) {
    return Reponse(
      id: json['id'],
     
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    
      'content': content,
    };
  }
}