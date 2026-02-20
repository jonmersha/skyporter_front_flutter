import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyporters/pages/auth/login_page.dart';

import 'chield/ProductRequestList.dart';
import 'chield/CustomerDealList.dart';
import 'chield/CustomerProfile.dart';
import 'chield/TripList.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  final storage = const FlutterSecureStorage();

  // Theme Colors - Matching your Passenger Card
  final Color primaryDark = const Color(0xFF1A1A1A); // Midnight Charcoal
  final Color accentGold = const Color(0xFFECAE0B);  // Golden Yellow
  final Color brandGreen = const Color(0xFF089348);  // Emerald Green

  final List<Widget> _pages = [
    const TripList(),
    const ProductRequestList(),
    const MyDealsPage(),
    const CustomerDealList(),
  ];

  // Future<void> _handleNavigation(int index) async {
  //   if (index == 2 || index == 3) {
  //     String? token = await storage.read(key: 'access');
  //
  //     if (token == null) {
  //       if (mounted) {
  //         final bool? loginSuccess = await Navigator.push<bool>(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => const LoginPage(),
  //             fullscreenDialog: true,
  //           ),
  //         );
  //
  //         if (loginSuccess == true) {
  //           setState(() => _currentIndex = index);
  //         }
  //       }
  //       return;
  //     }
  //   }
  //
  //   setState(() {
  //     _currentIndex = index;
  //   });
  // }

  // In MainNavigationPage.dart
  Future<void> _handleNavigation(int index) async {
    if (index == 2 || index == 3) {
      String? token = await storage.read(key: 'access');

      if (token == null) {
        if (mounted) {
          // IMPORTANT: Wait for the result of the LoginPage
          final bool? loginSuccess = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
              fullscreenDialog: true, // This makes it look like a slide-up tray
            ),
          );

          // ONLY change tab if login was confirmed successful
          if (loginSuccess == true) {
            setState(() {
              _currentIndex = index;
            });
          }
        }
        return;
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _handleNavigation,
          // Updated to match your high-contrast branding
          selectedItemColor: accentGold,
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: primaryDark,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.flight_takeoff_rounded),
                activeIcon: Icon(Icons.flight_takeoff_rounded, size: 28),
                label: 'Trips'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag_rounded, size: 28),
                label: 'Items'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.handshake_outlined),
                activeIcon: Icon(Icons.handshake_rounded, size: 28),
                label: 'Deals'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded, size: 28),
                label: 'Profile'
            ),
          ],
        ),
      ),
    );
  }
}