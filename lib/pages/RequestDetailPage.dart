import 'package:flutter/material.dart';
import 'package:skyporters/models/Customer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyporters/utils/api_constants.dart';

class RequestDetailPage extends StatefulWidget {
  final CustomerRequest request;
  const RequestDetailPage({super.key, required this.request});

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  final storage = const FlutterSecureStorage();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  // --- Logic: Create Enquiry based on your CURL ---
  Future<void> _createEnquiry() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      String? token = await storage.read(key: 'access');

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
        headers: {
          ...ApiConstants.authHeader(token!),
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "receiver": widget.request.customer, // The User ID from model
          "request": widget.request.id, // The Request ID from model
          "trip": null, // Explicitly null per your model
          "product": null, // Explicitly null per your model
          "message": _messageController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context); // Close sheet
          _messageController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Enquiry sent successfully!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        debugPrint("Error Response: ${response.body}");
      }
    } catch (e) {
      debugPrint("Connection Error: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showEnquirySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Send Enquiry",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tell the customer why you are a good fit...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _createEnquiry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SEND ENQUIRY",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Request Details"),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Travel Plan"),
                  _infoCard([
                    _infoRow(Icons.flight_takeoff, "Pick up",
                        widget.request.fromCity),
                    _infoRow(
                        Icons.flight_land, "Deliver to", widget.request.toCity),
                    _infoRow(
                        Icons.category, "Category", widget.request.category),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Description"),
                  Text(widget.request.description,
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey[700], height: 1.6)),
                  const SizedBox(height: 40),
                  _buildButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.indigo[900],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Text(widget.request.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _heroItem(
                  "Reward",
                  "\$${widget.request.budget.toStringAsFixed(0)}",
                  Colors.greenAccent),
              _heroItem("Timeline", widget.request.timelineStatus,
                  Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroItem(String label, String val, Color valColor) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(val,
            style: TextStyle(
                color: valColor, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo[900]),
          const SizedBox(width: 15),
          Text("$label: ", style: const TextStyle(color: Colors.grey)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[900])),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _showEnquirySheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[900],
            minimumSize: const Size(double.infinity, 55),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("SEND ENQUIRY",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),
        OutlinedButton(
          onPressed: () {}, // Formal Deal Logic
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            side: BorderSide(color: Colors.indigo[900]!),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("MAKE DIRECT OFFER",
              style: TextStyle(
                  color: Colors.indigo[900], fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
