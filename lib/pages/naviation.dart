import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'add.dart';
import 'home.dart';
import 'profile.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({Key? key}) : super(key: key);

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

/// This is the private State class that goes with NavigationPage.
class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List _widgetOptions = [
    HomePage(),
    AddPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Color(0xffF4B556),
        backgroundColor: Colors.white,
        height: 75,
        items: [
          Icon(
            Icons.home,
            color: Colors.white,
            size: 30,
          ),
          Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
          Icon(
            Icons.person,
            color: Colors.white,
            size: 30,
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
