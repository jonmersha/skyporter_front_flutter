import 'package:flutter/material.dart';
import 'package:skyporters/models/Trip.dart' show Trip;
import 'package:intl/intl.dart';

class TripListCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const TripListCard({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color departureColor = Color(0xFFECAE0B);
    const Color arrivalColor = Color(0xFF089348);
    const Color footerColor = Color(0xFF1A1A1A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        color: Colors.white,
        elevation: 1, // Lower elevation for a modern, flat marketplace look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade100),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // --- Top Row: Full Name & Status ---
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: footerColor,
                      child: Text(
                        // Extracts first letter of full name, handles empty cases
                        trip.travelerFullName.isNotEmpty
                            ? trip.travelerFullName[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trip.travelerFullName, // Displays Full Name
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Prevents overflow if name is very long
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCompactStatus(trip.isActive),
                  ],
                ),
                const SizedBox(height: 16),

                // --- Middle Row: Journey Details ---
                Row(
                  children: [
                    _buildCityBlock(
                        trip.departureCity,
                        DateFormat('dd MMM').format(trip.departureDate),
                        departureColor,
                        CrossAxisAlignment.start
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          Icon(Icons.flight_takeoff, size: 16, color: Colors.grey.shade400),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Divider(color: Colors.grey.shade200, thickness: 1),
                          ),
                        ],
                      ),
                    ),

                    _buildCityBlock(
                        trip.destinationCity,
                        DateFormat('dd MMM').format(trip.arrivalDate),
                        arrivalColor,
                        CrossAxisAlignment.end
                    ),
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
      flex: 4,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            city.toUpperCase(),
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D3436)
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
              date,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5
              )
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatus(bool isActive) {
    final Color color = isActive ? const Color(0xFF089348) : Colors.orange.shade900;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)
      ),
      child: Text(
        isActive ? "ACTIVE" : "PENDING",
        style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 0.5
        ),
      ),
    );
  }
}