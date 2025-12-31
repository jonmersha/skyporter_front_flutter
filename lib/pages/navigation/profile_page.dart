import 'package:flutter/material.dart';

import '../profile/identity_verification_page.dart';
import '../profile/my_listings_page.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF1A237E),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text("User Name", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Verified Level 2 ✅", style: TextStyle(color: Colors.green)),
          const Divider(height: 30),

          // --- Navigation Links ---
          _profileOption(
              context,
              Icons.list_alt,
              "My Listings (Trips & Requests)",
              const MyListingsPage()
          ),
          _profileOption(
              context,
              Icons.verified_user,
              "Identity Verification",
              const IdentityVerificationPage()
          ),
          _profileOption(
              context,
              Icons.account_balance_wallet,
              "Payout Settings",
              null // Placeholder
          ),
          _profileOption(
              context,
              Icons.history,
              "Deal History",
              null // Placeholder
          ),
          _profileOption(
              context,
              Icons.settings,
              "App Settings",
              null // Placeholder
          ),

          const Spacer(),
          TextButton.icon(
            onPressed: () {
              // Log out logic: Navigate back to RoleSelectionPage
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _profileOption(BuildContext context, IconData icon, String title, Widget? destination) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A237E)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Page coming soon!")),
          );
        }
      },
    );
  }
}