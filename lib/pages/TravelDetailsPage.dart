import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyporters/models/Trip.dart';
import 'package:skyporters/utils/api_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class TravelDetailsPage extends StatefulWidget {
  final Trip trip;
  const TravelDetailsPage({super.key, required this.trip});

  @override
  State<TravelDetailsPage> createState() => _TravelDetailsPageState();
}

class _TravelDetailsPageState extends State<TravelDetailsPage> {
  final storage = const FlutterSecureStorage();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  // Theme Colors
  final Color primaryNavy = const Color(0xFF1A1A1A);
  final Color accentGold = const Color(0xFFECAE0B);
  final Color brandGreen = const Color(0xFF089348);

  @override
  void initState() {
    super.initState();
    // Initialize with a default friendly message
    _messageController.text =
    "Hi ${widget.trip.travelerFullName}, I'm interested in your trip from ${widget.trip.departureCity} to ${widget.trip.destinationCity}.";
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Error opening app")));
      }
    }
  }


  // Future<void> _registerAndNotify() async {
  //   // 1. Validation Logic
  //   if (_messageController.text.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Please enter a message"))
  //     );
  //     return;
  //   }
  //
  //   // 2. ID Check: Ensures travelerId isn't 0 before sending
  //   if (widget.trip.travelerId == 0) {
  //     debugPrint("ERROR: travelerId is 0. Check if 'traveler' is in your Trip API response.");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Error: Traveler ID not found. Please refresh."),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }
  //
  //   setState(() => _isSending = true);
  //
  //   try {
  //     String? token = await storage.read(key: 'access');
  //
  //     // Exact headers from your working CURL
  //     final Map<String, String> headers = {
  //       'accept': 'application/json',
  //       'Content-Type': 'application/json',
  //       'Authorization': 'JWT $token',
  //     };
  //
  //     // Exact body structure as requested
  //     // widget.trip.travelerId provides the "receiver" ID
  //     final Map<String, dynamic> body = {
  //       "receiver": widget.trip.travelerId,
  //       "trip": widget.trip.id,
  //       "message": _messageController.text.trim(),
  //       "is_accepted": true,
  //     };
  //
  //     debugPrint("Attempting POST to Enquiry API with body: ${jsonEncode(body)}");
  //
  //     final response = await http.post(
  //       Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
  //       headers: headers,
  //       body: jsonEncode(body),
  //     );
  //
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text("Enquiry sent successfully!"),
  //             backgroundColor: Color(0xFF089348),
  //             behavior: SnackBarBehavior.floating,
  //           ),
  //         );
  //         // Return to the previous screen (Marketplace)
  //         Navigator.pop(context);
  //       }
  //     } else {
  //       // This will help you see if Django returns a specific field error
  //       debugPrint("Server Error Detail: ${response.body}");
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("Error: ${response.body}")),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Caught Network Error: $e");
  //   } finally {
  //     if (mounted) setState(() => _isSending = false);
  //   }
  // }
  // Future<void> _registerAndNotify() async {
  //   // 1. Validate the travelerId (Must be > 0)
  //   if (widget.trip.travelerId == 0) {
  //     debugPrint("DEBUG: Trip ID ${widget.trip.id} has travelerId 0. Check Django Serializer.");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Error: Traveler ID not found. Please refresh."),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }
  //
  //   if (_messageController.text.trim().isEmpty) return;
  //   setState(() => _isSending = true);
  //
  //   try {
  //     String? token = await storage.read(key: 'access');
  //     if (token == null) throw Exception("Session expired. Please login again.");
  //
  //     // Matching your working CURL headers
  //     final Map<String, String> headers = {
  //       'accept': 'application/json',
  //       'Content-Type': 'application/json',
  //       'Authorization': 'JWT $token',
  //     };
  //
  //     // Matching your exact requested body
  //     final Map<String, dynamic> body = {
  //       "receiver": widget.trip.travelerId, // Taken from Trip model
  //       "trip": widget.trip.id,             // Taken from Trip model
  //       "message": _messageController.text.trim(),
  //       "is_accepted": true,
  //     };
  //
  //     debugPrint("Sending Request: ${jsonEncode(body)}");
  //
  //     final response = await http.post(
  //       Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
  //       headers: headers,
  //       body: jsonEncode(body),
  //     );
  //
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //               content: Text("Enquiry sent successfully!"),
  //               backgroundColor: Color(0xFF089348),
  //               behavior: SnackBarBehavior.floating),
  //         );
  //         Navigator.pop(context);
  //       }
  //     } else {
  //       debugPrint("Server rejected request: ${response.body}");
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("Server Error: ${response.body}")),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Network Error: $e");
  //   } finally {
  //     if (mounted) setState(() => _isSending = false);
  //   }
  // }
  Future<void> _registerAndNotify() async {
    if (_messageController.text.trim().isEmpty) return;

    // Safety check: ensure the ID isn't 0 (which happens if the backend fix isn't applied)
    if (widget.trip.travelerId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Traveler ID missing. Check Django Serializer."))
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      String? token = await storage.read(key: 'access');

      // Headers matching your working curl
      final Map<String, String> headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'JWT $token',
      };

      // Body matching your exact requirement
      final Map<String, dynamic> body = {
        "receiver": widget.trip.travelerId, // Now this will be 1, not 0
        "trip": widget.trip.id,             // e.g., 1
        "message": _messageController.text.trim(),
        "is_accepted": true,
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Enquiry sent successfully!"),
                backgroundColor: Color(0xFF089348),
                behavior: SnackBarBehavior.floating),
          );
          Navigator.pop(context);
        }
      } else {
        debugPrint("Server Error Detail: ${response.body}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response.body}")),
          );
        }
      }
    } catch (e) {
      debugPrint("Flutter Error: $e");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Contact ${widget.trip.travelerFullName}"),
        backgroundColor: primaryNavy,
        elevation: 0,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeaderCard(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PERSONALIZE MESSAGE",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text("DIRECT CONTACT CHANNELS",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionCircle(Icons.phone_in_talk, "Call", Colors.blue.shade700,
                              () => _launchUrl("tel:${widget.trip.travelerPhone}")),
                      _buildActionCircle(Icons.chat_bubble_outline, "SMS", Colors.orange.shade800,
                              () => _launchUrl("sms:${widget.trip.travelerPhone}?body=${Uri.encodeComponent(_messageController.text)}")),
                      _buildActionCircle(FontAwesomeIcons.whatsapp, "WhatsApp", const Color(0xFF25D366),
                              () => _launchUrl("https://wa.me/${widget.trip.travelerPhone}?text=${Uri.encodeComponent(_messageController.text)}")),
                    ],
                  ),
                  _buildDivider(),
                  ElevatedButton(
                    onPressed: _isSending ? null : _registerAndNotify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: _isSending
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("OFFICIAL SKYPORT ENQUIRY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("OR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildActionCircle(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.25, height: 70,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
      decoration: BoxDecoration(color: primaryNavy, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRouteRow(widget.trip.departureCity, "ORIGIN", accentGold, Icons.radio_button_checked, true),
          _buildRouteRow(widget.trip.destinationCity, "DESTINATION", brandGreen, Icons.location_on, false),
        ],
      ),
    );
  }

  Widget _buildRouteRow(String city, String label, Color accent, IconData icon, bool showLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [Icon(icon, color: accent, size: 20), if (showLine) Container(width: 2, height: 30, color: Colors.white12)]),
        const SizedBox(width: 15),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: accent.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w900)),
            Text(city.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            if (showLine) const SizedBox(height: 10),
          ]),
        ),
      ],
    );
  }
}