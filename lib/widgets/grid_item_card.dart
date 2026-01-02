import 'package:flutter/material.dart';
import 'package:skyporters/models/trip.dart'; // Using the updated Trip model
import '../utils/constants.dart';

class GridItemCard extends StatelessWidget {
  final Trip journey;
  final VoidCallback onTap;

  const GridItemCard({super.key, required this.journey, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Section: Route ---
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flight_takeoff, size: 14, color: AppConstants.primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${journey.departureCity} - ${journey.destinationCity}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            // --- Content Section ---
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    journey.travelerName, // Updated from personName
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Arrives: ${journey.arrivalDate.toString().split(' ')[0]}",
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  const Divider(height: 16),
                  
                  // --- Quick Fees Preview ---
                  Text(
                    "Fees starting from:",
                    style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _badge("Laptop", Colors.indigo),
                      Text(
                        "\$${journey.laptopFee.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Colors.green, 
                          fontSize: 12
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(4)
      ),
      child: Text(
        label, 
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)
      ),
    );
  }
}