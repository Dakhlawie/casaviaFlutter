import 'package:casavia/Screens/core/booking.dart';
import 'package:casavia/Screens/core/search.dart';
import 'package:casavia/Screens/core/search_screen.dart';
import 'package:casavia/Screens/core/settings.dart';
import 'package:casavia/Screens/core/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    HomePage(),
    SearchPage(),
    BookingScreen(),
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
              icon: Icon(FontAwesomeIcons.gear), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    ));
  }
}
