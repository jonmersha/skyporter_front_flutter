import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:skyporters/pages/auth/login_page.dart';
import 'dart:convert';
import 'package:skyporters/utils/api_constants.dart';

import 'package:skyporters/pages/passenger/post_trip_page.dart';
import 'package:skyporters/pages/travler_product.dart';
import '../../post_request_page.dart';
import '../../profile/my_listings_page.dart';

class CustomerDealList extends StatefulWidget {
  const CustomerDealList({super.key});

  @override
  State<CustomerDealList> createState() => _CustomerDealListState();
}

class _CustomerDealListState extends State<CustomerDealList> {
  final storage = const FlutterSecureStorage();
  late Future<Map<String, dynamic>> _userDataFuture;

  // Skyport Brand Palette
  final Color primaryDark = const Color(0xFF1A1A1A);
  final Color accentGold = const Color(0xFFECAE0B);
  final Color brandGreen = const Color(0xFF089348);

  @override
  void initState() {
    super.initState();
    // Initialize the future once to prevent redundant API calls on rebuild
    _userDataFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    String? token = await storage.read(key: 'access');
    if (token == null) throw Exception("Session expired");

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.userMe),
        headers: ApiConstants.authHeader(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        _handleLogout();
        throw Exception("Unauthorized");
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection failed. Check internet.");
    }
  }

  Future<void> _handleLogout() async {
    await storage.deleteAll();
    if (mounted) {
      // Clear navigation stack and return to Login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // FutureBuilder optimizes the "Waiting" state
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentGold));
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final userData = snapshot.data!;
          final String username = userData['username'] ?? "User";

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(username),
              SliverToBoxAdapter(
                child: _buildListMenu(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(String username) {
    return SliverAppBar(
      expandedHeight: 180,
      backgroundColor: primaryDark,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accentGold, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey[800],
                    child: const Icon(Icons.person_outline, size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: brandGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          "VERIFIED LEVEL 2 ✅",
                          style: TextStyle(
                            color: brandGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
                  onPressed: _handleLogout,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListMenu() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildSectionHeader("MANAGE ACTIVITIES"),
        _profileOption(context, Icons.add_location_alt_rounded, "Post a New Trip", const PostTripPage(), accentGold),
        _profileOption(context, Icons.local_shipping_rounded, "Request Item Shipping", const PostProductRequest(), Colors.blueAccent),
        _profileOption(context, Icons.storefront_rounded, "Offer Item for Sale", const PostProductPage(), brandGreen),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Divider(thickness: 1, color: Color(0xFFE0E0E0)),
        ),

        _buildSectionHeader("ACCOUNT & SECURITY"),
        _profileOption(context, Icons.inventory_2_rounded, "My Listings", const CustomerActivityList(), primaryDark),
        _profileOption(context, Icons.verified_user_rounded, "Identity Verification", null, Colors.teal),
        _profileOption(context, Icons.settings_suggest_rounded, "Account Settings", null, Colors.blueGrey),

        const SizedBox(height: 40),
        _buildFooter(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11)),
      ),
    );
  }

  Widget _profileOption(BuildContext context, IconData icon, String title, Widget? destination, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.shade100),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF2D3436))),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
          onTap: () {
            if (destination != null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text("Something went wrong", style: TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
          Text(error, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() => _userDataFuture = _fetchUserData()),
            child: const Text("Retry"),
          ),
          TextButton(onPressed: _handleLogout, child: const Text("Logout"))
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text("SKYPORT SYSTEM", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 4),
        Text("Version 1.0.4", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }
}