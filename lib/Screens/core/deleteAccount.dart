import 'package:another_flushbar/flushbar.dart';
import 'package:casavia/Screens/core/security.dart';
import 'package:casavia/Screens/login/login_page.dart';
import 'package:casavia/model/accountClosure.dart';
import 'package:casavia/model/user.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/UserService.dart';
import 'package:casavia/services/accountClosureService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController reasonController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  String? username;
  String? email;
  void showFlushbar(BuildContext context, String message, Color color) {
    Flushbar(
      message: message,
      backgroundColor: color,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Future<void> _deleteAccount() async {
    if (reasonController.text.isEmpty) {
      showFlushbar(context,
          'Please provide a reason for deleting your account.', Colors.red);
    } else {
      try {
        int userId = Provider.of<UserModel>(context, listen: false).userId!;
        AccountClosure accountClosure = AccountClosure(
          username: username!,
          email: email!,
          message: reasonController.text,
        );

        await AccountClosureService().ajouterAccountClosure(accountClosure);

        await UserService().supprimerUser(userId);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        showFlushbar(context, 'Failed to delete account: $e', Colors.red);
      }
    }
  }

  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    int? userId = await authService.getUserIdFromToken();
    if (userId != null) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
      User? user = await UserService().getUserById(userId);
      username = '${user!.nom ?? ''} ${user!.prenom ?? ''}';
      email = user!.email ?? '';
    }
    print('USERID');
    print(userId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  Text(
                      'Do you have any feedback you  like to share before you go? We will use it to fix problems and improve our services  '),
                  SizedBox(height: 20),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        textSelectionTheme: TextSelectionThemeData(
                          cursorColor: Colors.blue[900],
                        ),
                        inputDecorationTheme: InputDecorationTheme(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue[900]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: reasonController,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "Your Reason...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
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
                            onPressed: () {
                              _deleteAccount();
                            },
                            child: Text(
                              'Delete account',
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
                ]),
          ),
        ),
      ),
    );
  }
}
