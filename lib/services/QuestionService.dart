import 'dart:convert';
import 'package:casavia/model/question.dart';
import 'package:http/http.dart' as http;

class QuestionService{
    final String baseUrl = "http://192.168.1.17:3000/question";
Future<Question> ajouterQuestion(Question question, int userId, int hebergementId) async {
    final uri = Uri.parse('$baseUrl/save').replace(queryParameters: {
      'user': userId.toString(),
      'hebergement': hebergementId.toString(),
    });
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': question.id,
        'content': question.content,
        'dateAsked': question.dateAsked.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return Question.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add question');
    }
}



  Future<List<Question>> findByUserAndHebergement(int hebergementId, int userId) async {
    final url = Uri.parse('$baseUrl/user/hebergement?hebergement=$hebergementId&user=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((question) => Question.fromJson(question)).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }


}