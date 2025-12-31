import 'package:flutter/material.dart';

class PostRequestPage extends StatefulWidget {
  const PostRequestPage({super.key});

  @override
  State<PostRequestPage> createState() => _PostRequestPageState();
}

class _PostRequestPageState extends State<PostRequestPage> {
  bool isPurchase = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request an Item")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInput("Product Name", Icons.shopping_bag),
            _buildInput("Pickup From (City/Country)", Icons.location_on),
            _buildInput("Deliver To (City/Country)", Icons.home),
            _buildInput("Weight (kg)", Icons.monitor_weight),
            SwitchListTile(
              title: const Text("I need the traveler to buy this for me"),
              value: isPurchase,
              onChanged: (v) => setState(() => isPurchase = v),
            ),
            if (isPurchase) _buildInput("Item Price (\$)", Icons.attach_money),
            _buildInput("Your Reward for Traveler (\$)", Icons.card_giftcard),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text("Post Request to Marketplace", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}