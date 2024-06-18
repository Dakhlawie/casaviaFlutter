import 'package:another_flushbar/flushbar.dart';
import 'package:casavia/model/contact.dart';
import 'package:casavia/model/notification.dart';
import 'package:casavia/services/ContactService.dart';
import 'package:casavia/services/notificationService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final ContactService _contactService = ContactService();
  final NotificationService _notificationService = NotificationService();
  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitContact() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _messageController.text.isEmpty) {
      Flushbar(
        message: "All fields must be filled.",
        backgroundColor: Colors.blue[900]!,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    if (!_isEmailValid(_emailController.text)) {
      Flushbar(
        message: "Please enter a valid email address.",
        backgroundColor: Colors.blue[900]!,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    Contact newContact = Contact(
      name: _nameController.text,
      email: _emailController.text,
      message: _messageController.text,
    );

    try {
      await _contactService.ajouterContact(newContact);
      NotificationMessage newNotification = NotificationMessage(
        title: "You have a new contact",
        date: DateTime.now(),
        seen: false,
        type: NotificationType.CONTACT,
      );

      await _notificationService.sendNotificationToPerson(newNotification, 1);
      await _contactService.sendEmail(
          _emailController.text, _nameController.text);
      Flushbar(
        message: "Your message added successfully!",
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    } catch (e) {
      Flushbar(
        message: "Failed to add contact: $e",
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Help',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'AbrilFatface',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'If you have any problem, you can leave your issue here.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Username',
                suffixIcon: IconButton(
                  icon: Icon(Icons.person, color: Colors.blue[900]),
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
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                suffixIcon: IconButton(
                  icon: Icon(Icons.email, color: Colors.blue[900]),
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
            SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your problem',
                suffixIcon: IconButton(
                  icon: Icon(Icons.text_fields, color: Colors.blue[900]),
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
                  onPressed: _submitContact,
                  child: Text(
                    'Send',
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
