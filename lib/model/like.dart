

import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/user.dart';

class Like {
  final int id;
  final User user;
  final Hebergement hebergement;
  final DateTime likedAt;

  Like(
      {required this.id,
      required this.user,
      required this.hebergement,
      required this.likedAt});

  factory Like.fromJson(Map<String, dynamic> json) {
    Like like = Like(
      id: json['id'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      hebergement:
          Hebergement.fromJson(json['hebergement'] as Map<String, dynamic>),
      likedAt: DateTime.parse(json['likedAt']),
    );
    print(like);
    return like;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'hebergement': hebergement.toJson(),
      'likedAt': likedAt.toIso8601String(),
    };
  }
}
