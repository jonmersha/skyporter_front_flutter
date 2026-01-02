// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:skyporters/pages/auth/login_page.dart';
// import 'dart:convert';

// import 'package:skyporters/utils/api_constants.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final storage = const FlutterSecureStorage();
//   String _username = "Loading...";
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }

//   // Fetch user data from Djoser /auth/users/me/
//   Future<void> _fetchUserData() async {
//     try {
//       String? token = await storage.read(key: 'access');

//       final response = await http.get(
//         Uri.parse(ApiConstants.userMe),
//         headers: ApiConstants.authHeader(token ?? ""),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _username =
//               data['username']; // 'username' is the default Djoser field
//           _isLoading = false;
//         });
//       } else if (response.statusCode == 401) {
//         // Token expired or invalid
//         _handleLogout();
//       }
//     } catch (e) {
//       setState(() {
//         _username = "Error loading name";
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _handleLogout() async {
//     await storage.deleteAll();
//     if (mounted) {
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("My Profile"), centerTitle: true),
//       body: Column(
//         children: [
//           const SizedBox(height: 20),
//           const CircleAvatar(
//             radius: 50,
//             backgroundColor: Color(0xFF1A237E),
//             child: Icon(Icons.person, size: 50, color: Colors.white),
//           ),
//           const SizedBox(height: 10),

//           // Display the dynamic username
//           _isLoading
//               ? const SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2))
//               : Text(_username,
//                   style: const TextStyle(
//                       fontSize: 22, fontWeight: FontWeight.bold)),

//           const Text("Verified Level 2 ✅",
//               style: TextStyle(color: Colors.green)),
//           const Divider(height: 30),

//           // --- Navigation Options ---
//           _profileOption(context, Icons.list_alt, "My Listings", null),
//           _profileOption(
//               context, Icons.verified_user, "Identity Verification", null),

//           const Spacer(),
//           TextButton.icon(
//             onPressed: _handleLogout,
//             icon: const Icon(Icons.logout, color: Colors.red),
//             label: const Text("Log Out", style: TextStyle(color: Colors.red)),
//           ),
//           const SizedBox(height: 30),
//         ],
//       ),
//     );
//   }

//   Widget _profileOption(
//       BuildContext context, IconData icon, String title, Widget? destination) {
//     return ListTile(
//       leading: Icon(icon, color: const Color(0xFF1A237E)),
//       title: Text(title),
//       trailing: const Icon(Icons.chevron_right, size: 20),
//       onTap: () {
//         if (destination != null) {
//           Navigator.push(
//               context, MaterialPageRoute(builder: (context) => destination));
//         }
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:skyporters/pages/auth/login_page.dart';
import 'dart:convert';
import 'package:skyporters/utils/api_constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = const FlutterSecureStorage();

  // State variables
  String _username = "";
  bool _isLoading = false;
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is called when the user switches to this tab.
    // We only trigger the API call if we haven't successfully loaded yet.
    if (!_hasLoaded && !_isLoading) {
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    // 1. Silent check for token
    String? token = await storage.read(key: 'access');
    if (token == null) return; // Stay dormant if not logged in

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.userMe),
        headers: ApiConstants.authHeader(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _username = data['username'];
            _isLoading = false;
            _hasLoaded = true; // Prevents background re-loading
          });
        }
      } else if (response.statusCode == 401) {
        _handleLogout();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _username = "Error loading profile";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    await storage.deleteAll();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        // Optional: Manual refresh button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUserData,
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // If we haven't even tried to load yet, show a clean placeholder
    if (!_hasLoaded && !_isLoading) {
      return const Center(child: Text("Select the profile tab to load info"));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF1A237E),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 15),

          // Dynamic Username Logic
          _isLoading
              ? const SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  _username,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),

          const Text("Verified Level 2 ✅",
              style: TextStyle(color: Colors.green)),
          const SizedBox(height: 20),
          const Divider(indent: 20, endIndent: 20),

          // --- Options List ---
          _profileOption(context, Icons.list_alt, "My Listings", null),
          _profileOption(
              context, Icons.verified_user, "Identity Verification", null),
          _profileOption(context, Icons.settings, "Account Settings", null),

          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label:
                    const Text("Log Out", style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _profileOption(
      BuildContext context, IconData icon, String title, Widget? destination) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A237E)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        if (destination != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destination));
        }
      },
    );
  }
}
