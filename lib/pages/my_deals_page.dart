import 'package:flutter/material.dart';

class MyDealsPage extends StatelessWidget {
  const MyDealsPage({super.key});

  // This helper maps the Django Status to Flutter Colors and Icons
  Map<String, dynamic> _getStatusTheme(String status) {
    switch (status) {
      case "PENDING":
        return {"color": Colors.grey, "icon": Icons.hourglass_empty};
      case "ACCEPTED":
        return {"color": Colors.indigo, "icon": Icons.check_circle_outline};
      case "PURCHASED":
        return {"color": Colors.orange, "icon": Icons.shopping_cart};
      case "IN_TRANSIT":
        return {"color": Colors.blue, "icon": Icons.local_shipping};
      case "ARRIVED":
        return {"color": Colors.teal, "icon": Icons.location_on};
      case "COMPLETED":
        return {"color": Colors.green, "icon": Icons.verified};
      default:
        return {"color": Colors.black, "icon": Icons.help_outline};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Deals"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDealCard(
            context,
            title: "iPhone 15 Pro Max",
            status: "IN_TRANSIT",
            role: "SENDER",
            partner: "Alex Rivera",
            price: 1200.0,
            reward: 50.0,
          ),
          _buildDealCard(
            context,
            title: "MacBook Pro M3",
            status: "PENDING",
            role: "TRAVELER",
            partner: "Sarah J.",
            price: 2500.0,
            reward: 150.0,
          ),
          _buildDealCard(
            context,
            title: "Nike Air Jordan",
            status: "COMPLETED",
            role: "SENDER",
            partner: "Michael K.",
            price: 0.0, // Delivery only
            reward: 30.0,
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard(
      BuildContext context, {
        required String title,
        required String status,
        required String role,
        required String partner,
        required double price,
        required double reward,
      }) {
    final theme = _getStatusTheme(status);
    final isTraveler = role == "TRAVELER";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: theme['color'].withOpacity(0.1),
              child: Icon(theme['icon'], color: theme['color']),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(isTraveler ? "Carrying for $partner" : "Being carried by $partner"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme['color'],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.replaceAll('_', ' '),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Reward", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("\$$reward", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to a specific Deal Status Update page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.indigo[900]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    isTraveler ? "Update Status" : "View Progress",
                    style: TextStyle(color: Colors.indigo[900]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}