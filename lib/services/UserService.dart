import 'dart:convert';
import 'dart:typed_data';
import 'package:casavia/model/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<void> supprimerUser(int id) async {
    final String baseUrl = 'http://192.168.1.17:3000/user';
    final url = Uri.parse('$baseUrl/delete/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  Future<Uint8List?> getImageFromFS(int id) async {
    final String url = 'http://192.168.1.17:3000/api/image/loadfromFS/$id';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Erreur: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'image: $e');
      return null;
    }
  }

  Future<void> uploadImageToServer(int id, Uint8List imageBytes) async {
    final String url = 'http://192.168.1.17:3000/api/image/uploadFS/$id';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'image.jpg',
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Error uploading image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<User> modifierUserNom(int id, String nom) async {
    final String url = 'http://192.168.1.17:3000/user/updatenom/$id';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: nom,
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Erreur lors de la modification du nom: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la modification du nom: $e');
    }
  }

  Future<User> modifierUserPrenom(int id, String prenom) async {
    final String url = 'http://192.168.1.17:3000/user/updateprenom/$id';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: prenom,
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Erreur lors de la modification du prenom: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la modification du prenom: $e');
    }
  }

  Future<User> modifierUserEmail(int id, String email) async {
    final String url = 'http://192.168.1.17:3000/user/updateemail/$id';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: email,
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Erreur lors de la modification du email: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la modification du email: $e');
    }
  }

  Future<User> modifierUserPays(int id, String pays) async {
    final String url = 'http://192.168.1.17:3000/user/updatepays/$id';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: pays,
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Erreur lors de la modification du pays: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la modification du pays: $e');
    }
  }

  Future<User> modifierUserPhone(int id, String phone) async {
    final String url = 'http://192.168.1.17:3000/user/updatetlf/$id';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: phone,
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Erreur lors de la modification du phone: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la modification du phone: $e');
    }
  }

  Future<User> modifierUserFlag(int id, String flag) async {
    final String url = 'http://192.168.1.17:3000/user/updateflag/$id';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: flag,
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Erreur lors de la modification du phone: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la modification du phone: $e');
    }
  }

  Future<User?> getUserById(int id) async {
    final String url = 'http://192.168.1.17:3000/user/$id';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print('getbyid');
        print(User.fromJson(jsonDecode(response.body)));
        return User.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  Future<bool> changePassword(
      int id, String currentPassword, String newPassword) async {
    final url = 'http://192.168.1.17:3000/user/change-password';

    final response = await http.put(Uri.parse(url), body: {
      'id': id.toString(),
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    return json.decode(response.body);
  }

  Future<User> fetchUserByEmail(String email) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.17:3000/user/findByEmail?email=$email'),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de la requête: ${response.statusCode}');
    }
  }

  Future<bool> checkIfUserExists(String email) async {
    print('hello');
    final response = await http.get(
      Uri.parse('http://192.168.1.17:3000/user/findByEmail?email=$email'),
    );

    if (response.statusCode == 200) {
      bool userExists = jsonDecode(response.body);
      print(userExists);
      return userExists;
    } else {
      throw Exception('Échec de la requête: ${response.statusCode}');
    }
  }

  Future<User?> findUserByEmail(String email) async {
    var url =
        Uri.parse('http://192.168.1.17:3000/user/findUserByEmail?email=$email');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var userData = jsonDecode(response.body);
        print(User.fromJson(userData));
        return User.fromJson(userData);
      } else {
        print("User not found, received status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred while fetching user: $e");
    }
    return null;
  }

  Future<String> sendRecoverEmail(
      String email, String firstname, String lastname) async {
    var url = Uri.parse('http://192.168.1.17:3000/user/recover');
    var response = await http.post(url, body: {
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
    });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to send recovery email. Status code: ${response.statusCode}');
    }
  }
}
