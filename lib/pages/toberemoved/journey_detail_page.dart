// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../models/journey_model.dart';
// import '../utils/constants.dart';
//
// class JourneyDetailPage extends StatelessWidget {
//   final Journey journey;
//   const JourneyDetailPage({super.key, required this.journey});
//
//   // Helper method for launching external apps (WhatsApp, Phone, etc.)
//   Future<void> _launch(Uri url) async {
//     if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//       debugPrint('Could not launch $url');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FD),
//       appBar: AppBar(
//         title: Text("Traveler: ${journey.personName}"),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildProfileHeader(),
//             const SizedBox(height: 24),
//             _buildTripCard(),
//             const SizedBox(height: 32),
//             const Text(
//               "Contact Options",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A237E)),
//             ),
//             const SizedBox(height: 16),
//             _buildContactGrid(),
//             const SizedBox(height: 32),
//             _buildBookingButton(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- WIDGET: Profile Header ---
//   Widget _buildProfileHeader() {
//     return Row(
//       children: [
//         const CircleAvatar(
//           radius: 35,
//           backgroundColor: Colors.indigo,
//           child: Icon(Icons.person, size: 40, color: Colors.white),
//         ),
//         const SizedBox(width: 16),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               journey.personName,
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const Row(
//               children: [
//                 Icon(Icons.verified, size: 16, color: Colors.green),
//                 SizedBox(width: 4),
//                 Text("Verified Carrier", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // --- WIDGET: The Beautified Trip Card ---
//   Widget _buildTripCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A237E), // Deep Indigo
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF1A237E).withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           )
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildFlightInfo("Departure", journey.departureTime, journey.route.split(' ➔ ')[0]),
//               const Icon(Icons.flight_takeoff, color: Colors.white54, size: 28),
//               _buildFlightInfo("Arrival", journey.arrivalTime, journey.route.split(' ➔ ')[1]),
//             ],
//           ),
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 20),
//             child: Divider(color: Colors.white24, thickness: 1),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildDetailItem(Icons.luggage, "Capacity", "${journey.totalLuggage} kg"),
//               _buildDetailItem(Icons.payments, "Price", "\$${journey.pricePerKg}/kg"),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFlightInfo(String label, String time, String city) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
//         Text(city, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//         Text(time, style: const TextStyle(color: Colors.white, fontSize: 14)),
//       ],
//     );
//   }
//
//   Widget _buildDetailItem(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.amber, size: 20),
//         const SizedBox(width: 8),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
//             Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
//           ],
//         )
//       ],
//     );
//   }
//
//   // --- WIDGET: Contact Actions Grid ---
//   Widget _buildContactGrid() {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       mainAxisSpacing: 12,
//       crossAxisSpacing: 12,
//       childAspectRatio: 2.2,
//       children: [
//         _contactBtn(Icons.phone, "Call", Colors.green, "tel:${journey.contactInfo}"),
//         _contactBtn(Icons.chat, "WhatsApp", const Color(0xFF25D366), "https://wa.me/${journey.contactInfo.replaceAll(' ', '')}"),
//         _contactBtn(Icons.send, "Telegram", const Color(0xFF0088cc), "https://t.me/SkyPorters_Support"),
//         _contactBtn(Icons.email, "Email", Colors.redAccent, "mailto:support@skyport.com"),
//       ],
//     );
//   }
//
//   Widget _contactBtn(IconData icon, String label, Color color, String url) {
//     return ElevatedButton.icon(
//       onPressed: () => _launch(Uri.parse(url)),
//       icon: Icon(icon, size: 18),
//       label: Text(label),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color.withOpacity(0.08),
//         foregroundColor: color,
//         elevation: 0,
//         alignment: Alignment.centerLeft,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(color: color.withOpacity(0.2)),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBookingButton() {
//     return ElevatedButton(
//       onPressed: () {},
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFF1A237E),
//         foregroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 56),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       ),
//       child: const Text("Book Delivery Request", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//     );
//   }
// }