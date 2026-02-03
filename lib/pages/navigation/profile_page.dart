import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:skyporters/pages/auth/login_page.dart';
import 'dart:convert';
import 'package:skyporters/utils/api_constants.dart';

import 'package:skyporters/pages/passenger/post_trip_page.dart';
import 'package:skyporters/pages/travler_product.dart';
import '../post_request_page.dart';
import '../profile/my_listings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = const FlutterSecureStorage();
  String _username = "Loading...";
  bool _isLoading = false;
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded && !_isLoading) {
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    String? token = await storage.read(key: 'access');
    if (token == null) return;
    setState(() => _isLoading = true);

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
            _hasLoaded = true;
          });
        }
      } else if (response.statusCode == 401) {
        _handleLogout();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 120, // Increased height for the profile info
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_username, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text("Verified Level 2 ✅", style: TextStyle(color: Colors.greenAccent, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white70),
                  onPressed: _handleLogout,
                )
              ],
            ),
          ),
        ),
      ),
      body: _buildListMenu(),
    );
  }

  Widget _buildListMenu() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildSectionHeader("MANAGE ACTIVITIES"),
        _profileOption(context, Icons.airplanemode_active, "Post a New Trip", const PostTripPage()),
        _profileOption(context, Icons.local_shipping_outlined, "Request Item Shipping", PostRequestPage()),
        _profileOption(context, Icons.add_shopping_cart, "Offer Item for Sale", const PostProductPage()),

        const Divider(height: 30),

        _buildSectionHeader("ACCOUNT & SECURITY"),
        _profileOption(context, Icons.list_alt, "My Listings", const MyListingsPage()),
        _profileOption(context, Icons.verified_user, "Identity Verification", null),
        _profileOption(context, Icons.settings, "Account Settings", null),

        const SizedBox(height: 20),
        Center(
          child: Text("Skyporters v1.0.4", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(title, style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 11)),
    );
  }

  Widget _profileOption(BuildContext context, IconData icon, String title, Widget? destination) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF1A237E).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF1A237E), size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: () {
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        }
      },
    );
  }
}