import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/passenger_post_model.dart';

class TravelDetailsPage extends StatelessWidget {
  final PassengerPost post;
  const TravelDetailsPage({super.key, required this.post});

  Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  // --- NEW: DEAL CREATION LOGIC ---
  void _initiateDeal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Create Deal Request",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("Request ${post.travelerName} to carry your item. They will review your request before the deal is confirmed."),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: POST to /api/deals/ in Django
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Deal Request Sent!"), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Confirm & Send Request", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Traveler Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFlightInfoCard(),
            const SizedBox(height: 24),
            const Text("Pricing Policy",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPriceRow("Standard Weight", "\$${post.pricePerKg}/kg", Icons.scale),
            _buildPriceRow("Laptops", "\$${post.laptopFee} per item", Icons.laptop_mac),
            _buildPriceRow("Smartphones", "\$${post.smartphoneFee} per item", Icons.phone_iphone),
            const SizedBox(height: 32),

            // MAIN ACTION: CREATE DEAL
            ElevatedButton(
              onPressed: () => _initiateDeal(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[900],
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              child: const Text("Book for My Item",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 12),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF1A237E),
            child: Icon(Icons.person, color: Colors.white)
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.travelerName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("Verified Traveler ✅",
                style: TextStyle(color: Colors.green, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildFlightInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _flightCol("From", post.from),
              const Icon(Icons.arrow_forward, color: Colors.white54),
              _flightCol("To", post.to),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _flightCol("Flight Date", post.date),
              _flightCol("Available", "${post.availableKg} kg"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _flightCol(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPriceRow(String label, String price, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(label),
      trailing: Text(price,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _launch("https://wa.me/${post.contact.replaceAll(' ', '')}"),
          icon: const Icon(Icons.chat),
          label: const Text("Chat on WhatsApp"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _launch("tel:${post.contact}"),
          icon: const Icon(Icons.phone),
          label: const Text("Call Directly"),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}