import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyporters/models/Trip.dart';
import 'package:skyporters/utils/api_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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
    _messageController.text =
    "Hi ${widget.trip.travelerName}, I'm interested in your trip from ${widget.trip.departureCity} to ${widget.trip.destinationCity}.";
  }

  String _getFormattedMessage() {
    return "[Skyport System]\n${_messageController.text}\n\nReason: Transportation Request";
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error opening app")));
    }
  }

  Future<void> _registerAndNotify() async {
    if (_messageController.text.trim().isEmpty) return;
    setState(() => _isSending = true);

    try {
      String? token = await storage.read(key: 'access');
      if (token == null) throw Exception("Please login to continue.");

      String? senderId = await storage.read(key: 'user_id');
      if (senderId == null) {
        final parts = token.split('.');
        final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
        senderId = payload['user_id'].toString();
        await storage.write(key: 'user_id', value: senderId);
      }

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
        headers: ApiConstants.authHeader(token),
        body: jsonEncode({
          "sender": int.parse(senderId),
          "receiver": widget.trip.travelerId,
          "message": _getFormattedMessage(),
          "trip": widget.trip.id,
          "product": null,
          "request": null,
          "is_accepted": false,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Enquiry sent successfully!"), backgroundColor: Color(0xFF089348)),
          );
        }
      } else {
        throw Exception("Failed to send enquiry.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullMsg = _getFormattedMessage();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Contact ${widget.trip.travelerName}"),
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
                  const Text("PERSONALIZE MESSAGE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Type your message here...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text("DIRECT CONTACT CHANNELS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionCircle(Icons.phone_in_talk, "Call", Colors.blue.shade700,
                              () => _launchUrl("tel:${widget.trip.travelerPhone}")),
                      _buildActionCircle(Icons.chat_bubble_outline, "SMS", Colors.orange.shade800,
                              () => _launchUrl("sms:${widget.trip.travelerPhone}?body=${Uri.encodeComponent(fullMsg)}")),
                      _buildActionCircle(FontAwesomeIcons.whatsapp, "WhatsApp", const Color(0xFF25D366),
                              () => _launchUrl("https://wa.me/${widget.trip.travelerPhone}?text=${Uri.encodeComponent(fullMsg)}")),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isSending ? null : _registerAndNotify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                      shadowColor: brandGreen.withOpacity(0.4),
                    ),
                    child: _isSending
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("OFFICIAL SKYPORT ENQUIRY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ],
              ),
            ),
          ),
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
            width: MediaQuery.of(context).size.width * 0.25,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
            ),
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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: primaryNavy,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRouteDisplay(widget.trip.departureCity, "ORIGIN", accentGold),
              Column(
                children: [
                  const Icon(Icons.flight_takeoff, color: Colors.white24, size: 20),
                  Container(height: 2, width: 40, color: Colors.white12),
                ],
              ),
              _buildRouteDisplay(widget.trip.destinationCity, "DESTINATION", brandGreen),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_available, color: Colors.white54, size: 14),
              const SizedBox(width: 6),
              Text(
                "Travel Date: ${DateFormat('MMMM dd, yyyy').format(widget.trip.arrivalDate)}",
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRouteDisplay(String city, String sub, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sub, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(
          city.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
      ],
    );
  }
}