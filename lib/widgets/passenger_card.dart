// import 'package:flutter/material.dart';
// import 'package:skyporters/models/Trip.dart' show Trip;
// import 'package:intl/intl.dart';
//
// class PassengerCard extends StatelessWidget {
//   final Trip trip;
//   final VoidCallback onTap;
//
//   const PassengerCard({
//     super.key,
//     required this.trip,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
//
//     // Defined Theme Colors
//     const Color departureColor = Color(0xFFECAE0B); // Golden Yellow
//     const Color arrivalColor = Color(0xFF089348);   // Emerald Green
//     const Color footerColor = Color(0xFF1A1A1A);    // Deep Anchor Charcoal
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       child: Card(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//           side: BorderSide(color: Colors.grey.shade100, width: 1.5),
//         ),
//         elevation: 8,
//         shadowColor: Colors.black.withOpacity(0.1),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(24),
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // --- Header ---
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildStatusChip(),
//                     Text(
//                       "ID #${trip.id}",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w900,
//                         color: Colors.grey.shade400,
//                         fontSize: 14,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 // --- Main Content ---
//                 if (isLandscape)
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(child: _buildStopSection("DEPARTURE", trip.departureDate, trip.departureCity, departureColor, Icons.flight_takeoff)),
//                       _buildLandscapeConnector(),
//                       Expanded(child: _buildStopSection("ARRIVAL", trip.arrivalDate, trip.destinationCity, arrivalColor, Icons.flight_land)),
//                     ],
//                   )
//                 else
//                   Column(
//                     children: [
//                       _buildStopSection("DEPARTURE", trip.departureDate, trip.departureCity, departureColor, Icons.flight_takeoff),
//                       _buildPortraitConnector(),
//                       _buildStopSection("ARRIVAL", trip.arrivalDate, trip.destinationCity, arrivalColor, Icons.flight_land),
//                     ],
//                   ),
//
//                 const SizedBox(height: 24),
//
//                 // --- Footer (Adjusted to Anchor the Colors) ---
//                 _buildTravelerFooter(footerColor),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStopSection(String label, DateTime date, String city, Color themeColor, IconData icon) {
//     return Row(
//       children: [
//         // High Contrast Date Box
//         Container(
//           width: 90,
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           decoration: BoxDecoration(
//             color: themeColor,
//             borderRadius: BorderRadius.circular(18),
//             boxShadow: [
//               BoxShadow(
//                 color: themeColor.withOpacity(0.3),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               )
//             ],
//           ),
//           child: Column(
//             children: [
//               Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
//               Text(DateFormat('dd').format(date), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
//               Text(DateFormat('MMM').format(date).toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
//             ],
//           ),
//         ),
//         const SizedBox(width: 16),
//         // City Info
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(icon, size: 16, color: themeColor),
//                   const SizedBox(width: 6),
//                   Text(
//                     label == "DEPARTURE" ? "FROM" : "TO",
//                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: themeColor),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 city.toUpperCase(),
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w900,
//                   color: Color(0xFF2D3436), // Deep Charcoal for readability
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPortraitConnector() {
//     return Container(
//       height: 30,
//       margin: const EdgeInsets.only(left: 45),
//       alignment: Alignment.centerLeft,
//       child: VerticalDivider(color: Colors.grey.shade200, thickness: 3),
//     );
//   }
//
//   Widget _buildLandscapeConnector() {
//     return Container(
//       width: 50,
//       height: 80,
//       alignment: Alignment.center,
//       child: Icon(Icons.double_arrow_rounded, color: Colors.grey.shade300, size: 28),
//     );
//   }
//
//   Widget _buildTravelerFooter(Color bgColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(
//             backgroundColor: Colors.white12,
//             radius: 18,
//             child: Icon(Icons.person, color: Colors.white, size: 22),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text("TRAVELER", style: TextStyle(fontSize: 9, color: Colors.white60, fontWeight: FontWeight.bold)),
//               Text(
//                 trip.travelerName,
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
//               ),
//             ],
//           ),
//           const Spacer(),
//           const Icon(Icons.verified_user, color: Colors.amber, size: 24),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatusChip() {
//     final bool isActive = trip.isActive;
//     final Color color = isActive ? const Color(0xFF089348) : Colors.orange.shade900;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircleAvatar(radius: 3, backgroundColor: color),
//           const SizedBox(width: 6),
//           Text(
//             isActive ? "ACTIVE" : "PENDING",
//             style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:skyporters/models/Trip.dart' show Trip;
import 'package:intl/intl.dart';

class PassengerCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const PassengerCard({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color departureColor = Color(0xFFECAE0B);
    const Color arrivalColor = Color(0xFF089348);
    const Color footerColor = Color(0xFF1A1A1A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Tight spacing
      child: Card(
        color: Colors.white,
        elevation: 2, // Lower elevation for cleaner list feel
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade100),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Reduced from 20
            child: Column(
              children: [
                // Top Row: Traveler & Status
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: footerColor,
                      child: Text(trip.travelerFullName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(trip.travelerFullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const Spacer(),
                    _buildCompactStatus(trip.isActive),
                  ],
                ),
                const SizedBox(height: 16),

                // Middle Row: The Journey (Horizontal)
                Row(
                  children: [
                    _buildCityBlock(trip.departureCity, DateFormat('dd MMM').format(trip.departureDate), departureColor, CrossAxisAlignment.start),

                    Expanded(
                      child: Column(
                        children: [
                          Icon(Icons.flight_takeoff, size: 16, color: Colors.grey.shade400),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Divider(color: Colors.grey.shade200, thickness: 1),
                          ),
                        ],
                      ),
                    ),

                    _buildCityBlock(trip.destinationCity, DateFormat('dd MMM').format(trip.arrivalDate), arrivalColor, CrossAxisAlignment.end),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCityBlock(String city, String date, Color color, CrossAxisAlignment alignment) {
    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(city.toUpperCase(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2D3436)),
              overflow: TextOverflow.ellipsis),
          Text(date, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCompactStatus(bool isActive) {
    final Color color = isActive ? const Color(0xFF089348) : Colors.orange.shade900;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(isActive ? "ACTIVE" : "PENDING",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color)),
    );
  }
}