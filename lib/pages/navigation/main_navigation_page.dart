// import 'package:flutter/material.dart';
// import 'package:skyporters/pages/navigation/traveler_marketplace_page.dart';
// import 'request_marketplace_page.dart';
// import '../my_deals_page.dart';
// import 'profile_page.dart';

// class MainNavigationPage extends StatefulWidget {
//   const MainNavigationPage({super.key});

//   @override
//   State<MainNavigationPage> createState() => _MainNavigationPageState();
// }

// class _MainNavigationPageState extends State<MainNavigationPage> {
//   int _currentIndex = 0;

//   final List<Widget> _pages = [
//     const TravelerMarketplacePage(), // For Senders to find Flights
//     const RequestMarketplacePage(), // For Passengers to find Items
//     const MyDealsPage(),
//     const ProfilePage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(index: _currentIndex, children: _pages),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//         selectedItemColor: Colors.indigo[900],
//         unselectedItemColor: Colors.grey,
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.flight), label: 'Travelers'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.local_mall), label: 'Requests'),
//           BottomNavigationBarItem(icon: Icon(Icons.handshake), label: 'Deals'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyporters/pages/auth/login_page.dart';
import 'package:skyporters/pages/navigation/traveler_marketplace_page.dart';
import 'RequestMarketPlace.dart';
import '../my_deals_page.dart';
import 'profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  // 1. App starts here at Index 0 (No login check performed)
  int _currentIndex = 0;
  final storage = const FlutterSecureStorage();

  final List<Widget> _pages = [
    const TravelerMarketplacePage(),
    const RequestMarketplacePage(),
    const MyDealsPage(),
    const ProfilePage(),
  ];

  // 2. This function ONLY triggers when a user taps the Bottom Bar
  Future<void> _handleNavigation(int index) async {
    // Check if the user clicked 'Deals' (2) or 'Profile' (3)
    if (index == 2 || index == 3) {
      String? token = await storage.read(key: 'access');

      // 3. Initiate login ONLY if they clicked these tabs and aren't logged in
      if (token == null) {
        if (mounted) {
          final bool? loginSuccess = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
              fullscreenDialog: true, // Optional: Makes it slide up like a tray
            ),
          );

          // 4. If login succeeds, switch to the requested tab
          if (loginSuccess == true) {
            setState(() => _currentIndex = index);
          }
        }
        return; // Stop here so the UI doesn't switch to Profile/Deals if login failed
      }
    }

    // 5. For Travelers (0) and Requests (1), always allow immediate navigation
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps the Marketplace loaded in the background
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: 'Travelers'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_mall), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.handshake), label: 'Deals'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
