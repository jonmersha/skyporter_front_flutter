import 'package:flutter/material.dart';
import '../models/passenger_post_model.dart';

class PassengerCard extends StatelessWidget {
  final PassengerPost post;
  final VoidCallback onTap; // Add this line

  const PassengerCard({
    super.key,
    required this.post,
    required this.onTap, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell( // Use InkWell for the ripple effect
        onTap: onTap, // Bind the callback here
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF1A237E),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          title: Text("${post.from} ➔ ${post.to}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Price: \$${post.pricePerKg}/kg • Laptop: \$${post.laptopFee}"),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${post.availableKg}kg",
                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
              const Text("Available", style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}