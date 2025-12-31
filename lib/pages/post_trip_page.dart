import 'package:flutter/material.dart';

class PostTripPage extends StatefulWidget {
  const PostTripPage({super.key});

  @override
  State<PostTripPage> createState() => _PostTripPageState();
}

class _PostTripPageState extends State<PostTripPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Your Trip")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInput("Departure City", Icons.flight_takeoff),
            _buildInput("Destination City", Icons.flight_land),
            _buildInput("Date of Flight", Icons.calendar_today),
            _buildInput("Available Weight (kg)", Icons.luggage),
            const Divider(height: 40),
            const Text("Special Item Pricing", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildInput("Price per kg (\$)", Icons.scale),
            _buildInput("Laptop Flat Fee (\$)", Icons.laptop),
            _buildInput("Smartphone Flat Fee (\$)", Icons.phone_android),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text("Publish My Trip", style: TextStyle(color: Colors.white)),
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