import 'dart:async';

import 'package:casavia/Screens/core/GeneralSettings.dart';
import 'package:casavia/Screens/core/Reviews.dart';
import 'package:casavia/Screens/core/accountSettings.dart';
import 'package:casavia/Screens/core/booking.dart';
import 'package:casavia/Screens/core/favorite.dart';
import 'package:casavia/Screens/core/help.dart';
import 'package:casavia/Screens/login/login_page.dart';
import 'package:casavia/model/user.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/UserService.dart';
import 'package:casavia/theme/color.dart';
import 'package:casavia/widgets/setting_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late final AuthService _authService;
  late final UserService _userService;
  Future<bool>? isLoggedInFuture;
  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _userService = UserService();
    _loadData();
  }

  void _loadData() {
    setState(() {
      isLoggedInFuture = _authService.isLoggedIn();
    });
  }

  int userId = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: 30),
          child: SingleChildScrollView(
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "Setting",
            style: TextStyle(
              color: AppColor.textColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return FutureBuilder<bool>(
      future: _authService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final isLoggedIn = snapshot.data;
            return SingleChildScrollView(
              padding: EdgeInsets.only(right: 20, top: 10),
              child: Column(
                children: [
                  _buildProfile(),
                  const SizedBox(height: 40),
                  if (isLoggedIn != null && isLoggedIn)
                    SettingItem(
                      title: "Manage your account",
                      leadingIcon: Icons.person,
                      leadingIconColor: Colors.blue[900],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AccountSettingsPage()),
                        );
                      },
                    ),
                  const SizedBox(height: 10),
                  SettingItem(
                    title: "General Setting",
                    leadingIcon: Icons.settings,
                    leadingIconColor: Colors.blue[900],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GeneralSettings()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  SettingItem(
                    title: "Help",
                    leadingIcon: Icons.bookmark_border,
                    leadingIconColor: Colors.blue[900],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HelpPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  SettingItem(
                    title: "Wishlists",
                    leadingIcon: Icons.favorite,
                    leadingIconColor: Colors.blue[900],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FavoritePage(
                                  userId: this.userId ?? 0,
                                )),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  SettingItem(
                    title: "Reviews",
                    leadingIcon: Icons.star,
                    leadingIconColor: Colors.blue[900],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReviewsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  SettingItem(
                    title: "Privacy",
                    leadingIcon: Icons.privacy_tip_outlined,
                    leadingIconColor: Colors.blue[900],
                  ),
                  const SizedBox(height: 10),
                  if (isLoggedIn != null && isLoggedIn)
                    SettingItem(
                      title: "Log Out",
                      leadingIcon: Icons.logout_outlined,
                      leadingIconColor: Colors.blue[900],
                      onTap: () {
                        _showConfirmLogout();
                      },
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildProfile() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _authService.getUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Erreur lors du chargement des données."));
        } else if (snapshot.hasData) {
          Map<String, dynamic>? userData = snapshot.data?['data'];
          int userId = userData?['user_id'] ?? 0;

          return FutureBuilder<User?>(
            future: UserService().getUserById(userId),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasError) {
                return Center(
                    child: Text("Erreur lors du chargement des données."));
              } else if (userSnapshot.hasData) {
                User? userDetails = userSnapshot.data;
                String username = userDetails?.nom ?? '';

                return Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Column(
                    children: [
                      ClipOval(
                        child: Image.network(
                          'http://192.168.1.17:3000/api/image/loadfromFS/$userId',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        username,
                        style: TextStyle(
                          color: AppColor.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Column(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/admin.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[900],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 50),
                          ),
                          child: Text('Login',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(left: 20),
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/admin.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                    ),
                    child: Text('Login', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  _showConfirmLogout() {
    final UserModel userModel = UserModel();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        message: Text("Would you like to log out?"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              await _authService.deleteToken();

              Navigator.pop(context); // Fermer le modal
              setState(() {});
              userModel.setUserId(0);
            },
            child: Text(
              "Log Out",
              style: TextStyle(color: AppColor.actionColor),
            ),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.blue[900]),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
