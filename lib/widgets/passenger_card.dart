import 'package:flutter/material.dart';
import 'package:skyporters/models/Trip.dart' show Trip;
// import '../models/trip.dart'; // Ensure correct path

class PassengerCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const PassengerCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15.0), // Increased padding for better feel
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top Section: Route and Status ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${trip.departureCity} ➔ ${trip.destinationCity}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 8),

              // --- Middle Section: Traveler and Date ---
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    trip.travelerName, // Updated from travelerUsername
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    trip.arrivalDate.toString().split(' ')[0],
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 0.5),

              // --- Bottom Section: The "Price Menu" Bar ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Space items evenly
                children: [
                  _priceBadge(Icons.laptop, trip.laptopFee),
                  _priceBadge(Icons.phone_iphone, trip.mobileFee),
                  _priceBadge(Icons.face, trip.cosmeticFee),
                  _priceBadge(Icons.inventory_2, trip.otherFee),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceBadge(IconData icon, double price) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.indigo[900]),
        const SizedBox(height: 4),
        Text(
          "\$${price.toStringAsFixed(0)}", // Formatted to 0 decimal places for clean UI
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trip.isActive ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        trip.isActive ? "ACTIVE" : "CLOSED",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: trip.isActive ? Colors.green[700] : Colors.red[700],
        ),
      ),
    );
  }
}