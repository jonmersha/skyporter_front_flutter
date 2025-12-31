import 'package:flutter/material.dart';
import 'package:skyporters/pages/navigation/traveler_marketplace_page.dart';
import 'request_marketplace_page.dart';
import '../my_deals_page.dart';
import 'profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TravelerMarketplacePage(), // For Senders to find Flights
    const RequestMarketplacePage(),  // For Passengers to find Items
    const MyDealsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.indigo[900],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: 'Travelers'),
          BottomNavigationBarItem(icon: Icon(Icons.local_mall), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.handshake), label: 'Deals'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}