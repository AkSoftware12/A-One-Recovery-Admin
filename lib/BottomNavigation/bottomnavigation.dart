import 'package:flutter/material.dart';

import '../HexColorCode/HexColor.dart';



class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<BottomNavigationPage> {
  int _selectedIndex = 0; // Tracks the selected tab

  // List of widgets to display for each tab
  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Home Page', style: TextStyle(fontSize: 24,color: Colors.white))),
    Center(child: Text('Search Page', style: TextStyle(fontSize: 24,color: Colors.white))),
    Center(child: Text('Profile Page', style: TextStyle(fontSize: 24,color: Colors.white))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#3a1e0d'),
      appBar: AppBar(
        backgroundColor: HexColor('#3a1e0d'),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('A1 Recovery',style: TextStyle(color: Colors.white),),
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: HexColor('#3a1e0d'),

        items: const <BottomNavigationBarItem>[

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Remove default padding
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: HexColor('#3a1e0d'),
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0; // Switch to Home tab
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Search'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1; // Switch to Search tab
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2; // Switch to Profile tab
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Handle settings tap (e.g., navigate to a settings page)
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
    );
  }
}