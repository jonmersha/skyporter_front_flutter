// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:skyporters/models/Trip.dart';
// import 'package:skyporters/utils/api_constants.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:intl/intl.dart';
//
// class TravelDetailsPage extends StatefulWidget {
//   final Trip trip;
//   const TravelDetailsPage({super.key, required this.trip});
//
//   @override
//   State<TravelDetailsPage> createState() => _TravelDetailsPageState();
// }
//
// class _TravelDetailsPageState extends State<TravelDetailsPage> {
//   final storage = const FlutterSecureStorage();
//   final TextEditingController _messageController = TextEditingController();
//   bool _isSending = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _messageController.text =
//     "Hi ${widget.trip.travelerName}, I saw your trip from ${widget.trip.departureCity} to ${widget.trip.destinationCity} on Skyport.";
//   }
//
//   // --- Logic Improvements ---
//
//   String _getFormattedMessage() {
//     return "[Skyport System]\n${_messageController.text}\n\nReason: Transportation Request";
//   }
//
//   int get _remainingDays {
//     final difference = widget.trip.arrivalDate.difference(DateTime.now()).inDays;
//     return difference < 0 ? 0 : difference;
//   }
//
//   Future<void> _launchUrl(String url) async {
//     final uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Could not open the requested app")),
//         );
//       }
//     }
//   }
//
//   // Future<void> _registerAndNotify() async {
//   //   if (_messageController.text.trim().isEmpty) return;
//   //
//   //   setState(() => _isSending = true);
//   //   try {
//   //     String? token = await storage.read(key: 'access');
//   //     if (token == null) throw Exception("Auth token not found");
//   //
//   //     final response = await http.post(
//   //       Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
//   //       headers: ApiConstants.authHeader(token),
//   //       body: jsonEncode({
//   //         "sender": currentUserId, // <--- Add this to match your curl
//   //         "trip": widget.trip.id,
//   //         "receiver": widget.trip.travelerId,
//   //         "message": _getFormattedMessage(),
//   //         "product": null,
//   //         "request": null,
//   //         "is_accepted": false,
//   //       }),
//   //     );
//   //
//   //     if (response.statusCode == 201) {
//   //       if (mounted) {
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           const SnackBar(
//   //             content: Text("Enquiry registered successfully!"),
//   //             backgroundColor: Colors.green,
//   //           ),
//   //         );
//   //         FocusScope.of(context).unfocus(); // Close keyboard
//   //       }
//   //     } else {
//   //       debugPrint("Error ${response.statusCode}: ${response.body}");
//   //       if (mounted) {
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           SnackBar(content: Text("Failed: ${response.body}")),
//   //         );
//   //       }
//   //     }
//   //   } catch (e) {
//   //     debugPrint("Network Error: $e");
//   //   } finally {
//   //     if (mounted) setState(() => _isSending = false);
//   //   }
//   // }
//   // Future<void> _registerAndNotify() async {
//   //   if (_messageController.text.trim().isEmpty) return;
//   //
//   //   setState(() => _isSending = true);
//   //
//   //   // Retrieve both token and user_id from storage
//   //   String? token = await storage.read(key: 'access');
//   //   String? userId = await storage.read(key: 'user_id'); // Ensure you save this during login
//   //
//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
//   //       headers: {
//   //         'Content-Type': 'application/json',
//   //         'Accept': 'application/json',
//   //         'Authorization': 'JWT $token',
//   //       },
//   //       body: jsonEncode({
//   //         "sender": 1, // Explicitly sending the sender ID
//   //         "receiver": widget.trip.travelerId,
//   //         "trip": widget.trip.id,
//   //         "message": _getFormattedMessage(),
//   //         "product": null,
//   //         "request": null,
//   //         "is_accepted": false,
//   //       }),
//   //     );
//   //
//   //     if (response.statusCode == 201) {
//   //       if (mounted) {
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           const SnackBar(
//   //             content: Text("Success! Enquiry registered on Skyport"),
//   //             backgroundColor: Colors.green,
//   //           ),
//   //         );
//   //         FocusScope.of(context).unfocus();
//   //       }
//   //     } else {
//   //       // Detailed error logging to see exactly what Django dislikes
//   //       final errorBody = jsonDecode(response.body);
//   //       debugPrint("Backend Error: $errorBody");
//   //       throw Exception(errorBody.toString());
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text("Error: ${e.toString().replaceAll('Exception:', '')}")),
//   //       );
//   //     }
//   //   } finally {
//   //     if (mounted) setState(() => _isSending = false);
//   //   }
//   // }
//   Future<void> _registerAndNotify() async {
//     if (_messageController.text.trim().isEmpty) return;
//
//     setState(() => _isSending = true);
//
//     try {
//       // 1. Retrieve auth data
//       String? token = await storage.read(key: 'access');
//       String? senderId = await storage.read(key: 'user_id');
//
//       if (token == null || senderId == null) {
//         throw Exception("Session expired. Please visit the Profile page.");
//       }
//
//       // 2. Execute the POST request
//       final url = Uri.parse("${ApiConstants.baseUrl}/api/enquiries/");
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'JWT $token',
//         },
//         body: jsonEncode({
//           "sender": int.parse(senderId),      // From logged-in user
//           "receiver": widget.trip.travelerId, // From the Trip model
//           "trip": widget.trip.id,
//           "message": _getFormattedMessage(),
//           "product": null,
//           "request": null,
//           "is_accepted": false,
//         }),
//       );
//
//       // 3. Handle Response matching your pattern
//       if (response.statusCode == 201) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Success! Enquiry registered on Skyport"),
//               backgroundColor: Colors.green,
//             ),
//           );
//           FocusScope.of(context).unfocus();
//         }
//       } else {
//         final errorBody = jsonDecode(response.body);
//         debugPrint("Backend Error: $errorBody");
//         throw Exception("Failed to send: $errorBody");
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error: ${e.toString().replaceAll('Exception:', '')}"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSending = false);
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     final fullMsg = _getFormattedMessage();
//     final phone = widget.trip.travelerPhone ?? "";
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text("Contact ${widget.trip.travelerName}",
//             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         backgroundColor: const Color(0xFF1A237E),
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           _buildHeaderCard(),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Your Message",
//                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   const SizedBox(height: 10),
//                   TextField(
//                     controller: _messageController,
//                     maxLines: 3,
//                     onChanged: (v) => setState(() {}),
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                       hintText: "Type your message here...",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 25),
//                   const Text("Direct Contact",
//                       style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 15),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _buildActionCircle(Icons.phone, "Call", Colors.blue,
//                           phone.isEmpty ? null : () => _launchUrl("tel:$phone")),
//                       _buildActionCircle(Icons.sms, "SMS", Colors.orange,
//                           phone.isEmpty ? null : () => _launchUrl("sms:$phone?body=${Uri.encodeComponent(fullMsg)}")),
//                       _buildActionCircle(FontAwesomeIcons.whatsapp, "WhatsApp", const Color(0xFF25D366),
//                           phone.isEmpty ? null : () => _launchUrl("https://wa.me/$phone?text=${Uri.encodeComponent(fullMsg)}")),
//                     ],
//                   ),
//                   const SizedBox(height: 35),
//                   ElevatedButton.icon(
//                     onPressed: _isSending ? null : _registerAndNotify,
//                     icon: _isSending
//                         ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                         : const Icon(Icons.app_registration, color: Colors.white),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF1A237E),
//                       minimumSize: const Size(double.infinity, 55),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                     ),
//                     label: const Text("Register on Skyport System",
//                         style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionCircle(IconData icon, String label, Color color, VoidCallback? onTap) {
//     return Opacity(
//       opacity: onTap == null ? 0.4 : 1.0,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(15),
//         child: Column(
//           children: [
//             Container(
//               width: 80,
//               height: 60,
//               decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(15)
//               ),
//               child: Icon(icon, color: color, size: 28),
//             ),
//             const SizedBox(height: 8),
//             Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderCard() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
//       decoration: const BoxDecoration(
//         color: Color(0xFF1A237E),
//         borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildRouteCity(widget.trip.departureCity, "Departure"),
//               const Icon(Icons.flight_takeoff, color: Colors.white54, size: 30),
//               _buildRouteCity(widget.trip.destinationCity, "Destination"),
//             ],
//           ),
//           const SizedBox(height: 20),
//           const Divider(color: Colors.white24),
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildInfoRow(Icons.calendar_today, DateFormat('MMM dd, yyyy').format(widget.trip.arrivalDate)),
//               _buildInfoRow(Icons.timer, "$_remainingDays Days Left"),
//             ],
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRouteCity(String city, String label) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.1)),
//         Text(city, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.white54, size: 16),
//         const SizedBox(width: 8),
//         Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
//       ],
//     );
//   }
// }

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

  @override
  void initState() {
    super.initState();
    _messageController.text =
    "Hi ${widget.trip.travelerName}, I saw your trip from ${widget.trip.departureCity} to ${widget.trip.destinationCity} on Skyport.";
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

  // Future<void> _registerAndNotify() async {
  //   if (_messageController.text.trim().isEmpty) return;
  //
  //   setState(() => _isSending = true);
  //
  //   try {
  //     String? token = await storage.read(key: 'access');
  //     String? senderId = await storage.read(key: 'user_id');
  //
  //     if (token == null || senderId == null) {
  //       throw Exception("Authentication required. Please refresh your profile.");
  //     }
  //
  //     final response = await http.post(
  //       Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
  //       headers: ApiConstants.authHeader(token),
  //       body: jsonEncode({
  //         "sender": int.parse(senderId),      // Fixes the 'sender required' error
  //         "receiver": widget.trip.travelerId,
  //         "trip": widget.trip.id,
  //         "message": _getFormattedMessage(),
  //         "product": null,
  //         "request": null,
  //         "is_accepted": false,
  //       }),
  //     );
  //
  //     if (response.statusCode == 201) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Success! Enquiry registered on Skyport"), backgroundColor: Colors.green),
  //         );
  //         FocusScope.of(context).unfocus();
  //       }
  //     } else {
  //       final errorBody = jsonDecode(response.body);
  //       throw Exception(errorBody.toString());
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Error: ${e.toString().replaceAll('Exception:', '')}")),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isSending = false);
  //   }
  // }
  Future<void> _registerAndNotify() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      String? token = await storage.read(key: 'access');
      if (token == null) throw Exception("Please login to continue.");

      // IMPROVEMENT: If user_id isn't in storage, extract it from the JWT token
      String? senderId = await storage.read(key: 'user_id');

      if (senderId == null) {
        // Decode the JWT to get the user_id (the middle part of the token)
        final parts = token.split('.');
        final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
        );
        senderId = payload['user_id'].toString();
        // Save it now so we have it next time
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
            const SnackBar(content: Text("Enquiry sent successfully!"), backgroundColor: Colors.green),
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception("Session expired. Please log in again.");
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody.toString());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString().replaceAll('Exception:', '')}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullMsg = _getFormattedMessage();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Contact ${widget.trip.travelerName}"),
        backgroundColor: const Color(0xFF1A237E),
        centerTitle: true,
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
                  const Text("Your Message", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    onChanged: (v) => setState(() {}),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Direct Sending Options Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionCircle(Icons.phone, "Call", Colors.blue,
                              () => _launchUrl("tel:${widget.trip.travelerPhone}")),
                      _buildActionCircle(Icons.sms, "SMS", Colors.orange,
                              () => _launchUrl("sms:${widget.trip.travelerPhone}?body=${Uri.encodeComponent(fullMsg)}")),
                      _buildActionCircle(FontAwesomeIcons.whatsapp, "WhatsApp", const Color(0xFF25D366),
                              () => _launchUrl("https://wa.me/${widget.trip.travelerPhone}?text=${Uri.encodeComponent(fullMsg)}")),
                    ],
                  ),
                  const SizedBox(height: 35),
                  ElevatedButton(
                    onPressed: _isSending ? null : _registerAndNotify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isSending
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Register on Skyport", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            width: 80, height: 60,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildRouteCity(widget.trip.departureCity, "Departure"),
          const Icon(Icons.flight_takeoff, color: Colors.white54),
          _buildRouteCity(widget.trip.destinationCity, "Destination"),
        ],
      ),
    );
  }

  Widget _buildRouteCity(String city, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        Text(city, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}