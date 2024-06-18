import 'package:another_flushbar/flushbar.dart';
import 'package:casavia/Screens/core/validEmail.dart';
import 'package:casavia/model/user.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateMailPage extends StatefulWidget {
  const UpdateMailPage({super.key});

  @override
  State<UpdateMailPage> createState() => _UpdateMailPageState();
}

class _UpdateMailPageState extends State<UpdateMailPage> {
  void showFlushbar(BuildContext context, String message, Color color) {
    Flushbar(
      message: message,
      backgroundColor: color,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  UserService userService = UserService();
  AuthService authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  String _currentEmail = '';

  @override
  void initState() {
    super.initState();
    setState(() {});
    _fetchUserId();
  }

  int? userId;
  Future<void> _fetchUserId() async {
    userId = await authService.getUserIdFromToken();
    if (userId != null) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId!);
      User? user = await userService.getUserById(userId!);
      if (user != null) {
        setState(() {
          _currentEmail = user.email;
          _emailController.text = user.email;
        });
      }
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void _saveEmail() async {
    String newEmail = _emailController.text;

    if (!_isValidEmail(newEmail)) {
      Flushbar(
        message: 'Please enter a valid email address.',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }
    if (newEmail == _currentEmail) {
      Flushbar(
        message: 'The new email cannot be the same as the current email.',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }
    try {
      User? existingUser = await userService.findUserByEmail(newEmail);
      if (existingUser != null) {
        Flushbar(
          message: 'Email already exists.',
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
        return;
      }
    } catch (e) {
      Flushbar(
        message: 'Error occurred while checking email: $e',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ValidEmailPage(email: newEmail, id: userId!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserModel>(context).userId;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'AbrilFatface',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'You must enter a valid email to update your email.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'email',
                suffixIcon: IconButton(
                  icon: Icon(Icons.mail, color: Colors.blue[900]),
                  onPressed: () {},
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.blue[900]!),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: TextButton(
                  onPressed: _saveEmail,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
