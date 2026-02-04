import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/api_constants.dart';

class CreateEnquiryPage extends StatefulWidget {
  final dynamic source; // Can be Trip, TravelerProduct, or CustomerRequest
  final int receiverId;
  final String receiverName;

  const CreateEnquiryPage({
    super.key,
    required this.source,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<CreateEnquiryPage> createState() => _CreateEnquiryPageState();
}

class _CreateEnquiryPageState extends State<CreateEnquiryPage> {
  final _messageController = TextEditingController();
  final storage = const FlutterSecureStorage();
  bool _isLoading = false;

  Future<void> _sendEnquiry() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    String? token = await storage.read(key: 'access');

    // Identify which ID to send based on the object type
    Map<String, dynamic> body = {
      "receiver": widget.receiverId,
      "message": _messageController.text.trim(),
    };

    // Dynamically assign the source ID
    final type = widget.source.runtimeType.toString();
    if (type == 'Trip') body['trip'] = widget.source.id;
    if (type == 'TravelerProduct') body['product'] = widget.source.id;
    if (type == 'CustomerRequest') body['request'] = widget.source.id;

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Enquiry sent!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        print("Error: ${response.body}");
        throw Exception("Failed to send enquiry");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enquiry to ${widget.receiverName}")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSourcePreview(),
            const SizedBox(height: 20),
            const Text("Your Message", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Ask about availability, price, or delivery details...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendEnquiry,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: const Color(0xFF1A237E),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Send Enquiry", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourcePreview() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF1A237E)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "Regarding: ${widget.source.title ?? 'Selected Item'}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}