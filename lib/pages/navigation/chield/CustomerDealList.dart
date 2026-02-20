import 'package:flutter/material.dart';

class MyDealsPage extends StatelessWidget {
  const MyDealsPage({super.key});

  // Brand Palette
  final Color primaryDark = const Color(0xFF1A1A1A);
  final Color accentGold = const Color(0xFFECAE0B);
  final Color brandGreen = const Color(0xFF089348);

  Map<String, dynamic> _getStatusTheme(String status) {
    switch (status) {
      case "PENDING":
        return {"color": Colors.orange.shade800, "icon": Icons.hourglass_top_rounded};
      case "ACCEPTED":
        return {"color": Colors.blue.shade700, "icon": Icons.handshake_rounded};
      case "PURCHASED":
        return {"color": Colors.purple.shade700, "icon": Icons.shopping_bag_rounded};
      case "IN_TRANSIT":
        return {"color": const Color(0xFFECAE0B), "icon": Icons.local_airport_rounded};
      case "ARRIVED":
        return {"color": Colors.teal.shade700, "icon": Icons.location_on_rounded};
      case "COMPLETED":
        return {"color": const Color(0xFF089348), "icon": Icons.verified_rounded};
      default:
        return {"color": Colors.grey, "icon": Icons.help_outline};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryDark,
        title: const Text("My Deals",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list_rounded, color: Colors.white)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildDealCard(
            context,
            title: "iPhone 15 Pro Max",
            status: "IN_TRANSIT",
            role: "SENDER",
            partner: "Alex Rivera",
            reward: 50.0,
          ),
          _buildDealCard(
            context,
            title: "MacBook Pro M3",
            status: "PENDING",
            role: "TRAVELER",
            partner: "Sarah J.",
            reward: 150.0,
          ),
          _buildDealCard(
            context,
            title: "Nike Air Jordan",
            status: "COMPLETED",
            role: "SENDER",
            partner: "Michael K.",
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
        required double reward,
      }) {
    final theme = _getStatusTheme(status);
    final isTraveler = role == "TRAVELER";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header Strip indicating Role
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
              color: isTraveler ? brandGreen.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              child: Text(
                isTraveler ? "YOUR EARNING OPPORTUNITY" : "YOUR SHIPMENT",
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: isTraveler ? brandGreen : Colors.blue.shade800
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(theme['icon'], color: theme['color'], size: 28),
              ),
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF2D3436))),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isTraveler ? "Carrying for $partner" : "Handled by $partner",
                  style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            // Middle Progress Indicator Bar (Subtle)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: theme['color'], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(width: 8),
                  Text(status.replaceAll('_', ' '),
                      style: TextStyle(color: theme['color'], fontWeight: FontWeight.w900, fontSize: 10)),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isTraveler ? "YOU EARN" : "FEE PAID",
                          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      const SizedBox(height: 2),
                      Text("\$${reward.toStringAsFixed(2)}",
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: brandGreen)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      isTraveler ? "UPDATE" : "DETAILS",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}