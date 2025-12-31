import 'package:flutter/material.dart';
import 'registration_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Color(0xFF1A237E), Color(0xFF3F51B5)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.public, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "Welcome to SkyPorters",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "How would you like to join us today?",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 50),
            _roleButton(
              context,
              title: "I am a Customer",
              subtitle: "I want to send or buy items abroad",
              icon: Icons.shopping_bag,
              isTraveler: false,
            ),
            const SizedBox(height: 20),
            _roleButton(
              context,
              title: "I am a Traveler",
              subtitle: "I want to earn by sharing luggage space",
              icon: Icons.flight_takeoff,
              isTraveler: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(BuildContext context, {required String title, required String subtitle, required IconData icon, required bool isTraveler}) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RegistrationPage(isTraveler: isTraveler)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isTraveler ? Colors.indigo : Colors.green,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}