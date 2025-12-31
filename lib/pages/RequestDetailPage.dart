import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/customer_request_model.dart';

class RequestDetailPage extends StatelessWidget {
  final CustomerRequest request;
  const RequestDetailPage({super.key, required this.request});

  Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  // --- NEW: DEAL CREATION LOGIC ---
  void _createDealOffer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Offer to Carry"),
        content: Text("Do you want to offer to carry '${request.productName}' to ${request.to}? This will notify the sender to review your profile."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Perform POST request to /api/deals/ in Django
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Offer sent to the sender!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Confirm Offer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Item Request Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRewardCard(),
            const SizedBox(height: 24),
            const Text("Item Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _infoTile("Product", request.productName, Icons.shopping_bag),
            _infoTile("Route", "${request.from} ➔ ${request.to}", Icons.map),
            _infoTile("Weight", "${request.weight} kg", Icons.monitor_weight),
            _infoTile("Type", request.isPurchaseRequired ? "Buy & Deliver" : "Delivery Only", Icons.info),

            if (request.isPurchaseRequired)
              _infoTile("Item Price", "\$${request.itemPrice}", Icons.attach_money),

            const SizedBox(height: 32),

            // MAIN ACTION: CREATE DEAL
            ElevatedButton(
              onPressed: () => _createDealOffer(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Offer to Carry This Item",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 12),

            // SECONDARY ACTION: CHAT
            OutlinedButton.icon(
              onPressed: () => _launch("https://wa.me/${request.contact.replaceAll(' ', '')}"),
              icon: const Icon(Icons.chat, color: Colors.indigo),
              label: const Text("Chat with Sender"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                side: const BorderSide(color: Colors.indigo),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          const Text("Your Potential Earnings",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text("\$${request.deliveryReward}",
              style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
          const Text("Delivery Reward",
              style: TextStyle(color: Colors.white, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String val, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: Colors.indigo, size: 20),
        ),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(val,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }
}