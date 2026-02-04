// enquiry_helper.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:skyporters/utils/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EnquiryHandler {
  static const storage = FlutterSecureStorage();

  static Future<void> showEnquirySheet({
    required BuildContext context,
    required int receiverId,
    required int sourceId,
    required String sourceTitle,
    required String sourceType, // 'trip', 'product', or 'request'
  }) async {
    final TextEditingController messageController = TextEditingController(
        text: "Hi, I'm interested in your $sourceType: $sourceTitle. Let's discuss the details."
    );
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Send Enquiry", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter your message...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isSending ? null : () async {
                  setSheetState(() => isSending = true);

                  String? token = await storage.read(key: 'access');
                  try {
                    final response = await http.post(
                      Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
                      headers: {
                        ...ApiConstants.authHeader(token!),
                        "Content-Type": "application/json",
                      },
                      body: jsonEncode({
                        "receiver": receiverId,
                        sourceType: sourceId, // e.g., "product": 5 or "request": 2
                        "message": messageController.text,
                      }),
                    );

                    if (response.statusCode == 201) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enquiry Sent!"), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    debugPrint("Error: $e");
                  } finally {
                    setSheetState(() => isSending = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Send Message", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}