import 'package:casavia/Screens/core/Chat.dart';
import 'package:casavia/Screens/core/booking.dart';
import 'package:casavia/Screens/core/findPage.dart';
import 'package:casavia/Screens/core/search.dart';
import 'package:casavia/Screens/core/search_screen.dart';
import 'package:casavia/Screens/core/settings.dart';
import 'package:casavia/Screens/core/home.dart';
import 'package:casavia/Screens/firstScreen.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/conversationService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _unseenMessagesCount = 0;
  final ConversationService conversationServ = ConversationService();
  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUnseenMessagesCount(int userId) async {
    try {
      int count = await conversationServ.countUnseenMessagesByUser(userId);
      setState(() {
        _unseenMessagesCount = count;
      });
    } catch (e) {
      print('Failed to count unseen messages: $e');
    }
  }

  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    int? userId = await authService.getUserIdFromToken();
    if (userId != null) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
      _fetchUnseenMessagesCount(userId);
    }
    print('USERID');
    print(userId);
  }

  @override
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    FirstScreen(),
    FindPage(),
    BookingScreen(),
    ChatPage(),
    SettingPage(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.briefcase), label: 'Bookings'),
          BottomNavigationBarItem(
              icon: Stack(
                children: <Widget>[
                  Icon(FontAwesomeIcons.comments),
                  if (_unseenMessagesCount > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '$_unseenMessagesCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.gear), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    ));
  }
}
