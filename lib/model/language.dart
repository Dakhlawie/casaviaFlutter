import 'package:http/http.dart';

class Language {
  int language_id;
  String language;

  Language({
    required this.language_id,
    required this.language,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    Language l = Language(
      language_id: json['language_id'],
      language: json['language'],
    );

    return l;
  }

  Map<String, dynamic> toJson() => {
        'language_id': language_id,
        'language': language,
      };
}
