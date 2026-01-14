import 'package:flutter/material.dart';
// import 'package:skyporters/models/trip.dart'; // Ensure correct path
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyporters/models/Trip.dart';
import 'package:skyporters/utils/api_constants.dart';

class TravelDetailsPage extends StatefulWidget {
  final Trip trip;
  const TravelDetailsPage({super.key, required this.trip});

  @override
  State<TravelDetailsPage> createState() => _TravelDetailsPageState();
}

class _TravelDetailsPageState extends State<TravelDetailsPage> {
  final storage = const FlutterSecureStorage();
  bool _isSending = false;

  Future<void> _sendEnquiry(BuildContext context, String message) async {
    setState(() => _isSending = true);
    try {
      String? token = await storage.read(key: 'access');

      if (token == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please login to contact the traveler")),
          );
        }
        return;
      }

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
        headers: {
          ...ApiConstants.authHeader(token),
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "receiver": widget.trip.travelerId,
          "trip": widget.trip.id,
          "message": message,
        }),
      );

      if (response.statusCode == 201) {
        if (context.mounted) {
          Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Enquiry Sent!"), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      debugPrint("Enquiry Error: $e");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showEnquirySheet() {
    final TextEditingController messageController = TextEditingController(
      text: "Hi, I'm interested in your trip to ${widget.trip.destinationCity}. I have an item I'd like you to carry."
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder( // Added to handle loading state inside sheet
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Contact Traveler", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter your message...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSending ? null : () async {
                  setSheetState(() => _isSending = true);
                  await _sendEnquiry(context, messageController.text);
                  setSheetState(() => _isSending = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSending 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Send Enquiry", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFlightInfoCard(),
            const SizedBox(height: 32),
            const Text("Carrying Fees", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPriceRow("Laptops", "\$${widget.trip.laptopFee}", Icons.laptop),
            _buildPriceRow("Mobile Phones", "\$${widget.trip.mobileFee}", Icons.phone_android),
            _buildPriceRow("Cosmetics", "\$${widget.trip.cosmeticFee}", Icons.face),
            _buildPriceRow("General Items", "\$${widget.trip.otherFee}", Icons.inventory_2),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _showEnquirySheet,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text("Request Transport", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(radius: 30, backgroundColor: Color(0xFF1A237E), child: Icon(Icons.person, color: Colors.white)),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.trip.travelerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Row(
              children: [
                Icon(Icons.verified, color: Colors.blue, size: 16),
                SizedBox(width: 4),
                Text("Verified Traveler", style: TextStyle(color: Colors.blue, fontSize: 13)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlightInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _flightCol("From", widget.trip.departureCity),
              const Icon(Icons.flight_takeoff, color: Colors.white54),
              _flightCol("To", widget.trip.destinationCity),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _flightCol("Arrival", widget.trip.arrivalDate.toString().split(' ')[0]),
              _flightCol("Status", widget.trip.isActive ? "Active" : "Closed"),
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
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildPriceRow(String label, String price, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo[900]),
      title: Text(label),
      trailing: Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
    );
  }
}