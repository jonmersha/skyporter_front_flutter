import 'package:flutter/material.dart';

class IdentityVerificationPage extends StatelessWidget {
  const IdentityVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Identity")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.verified_user, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text("Upload your Passport or ID to become a Verified Traveler.", textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () {}, child: const Text("Upload Document")),
          ],
        ),
      ),
    );
  }
}