// import 'package:flutter/material.dart';
// import 'package:skyporters/models/Customer.dart';
//
//
// class CustomerRequestCard extends StatelessWidget {
//   final CustomerRequest request;
//   final VoidCallback onTap;
//
//   const CustomerRequestCard({
//     super.key,
//     required this.request,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Helper to pick icon based on the Django Category choice
//     IconData getCategoryIcon(String category) {
//       switch (category.toUpperCase()) {
//         case 'ELECTRONICS': return Icons.devices;
//         case 'MEDICINES': return Icons.medical_services;
//         case 'FOOD_SUPPLEMENTS': return Icons.restaurant;
//         case 'COSMETICS': return Icons.face;
//         default: return Icons.shopping_bag;
//       }
//     }
//
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Row(
//             children: [
//               // --- Leading Icon ---
//               CircleAvatar(
//                 radius: 25,
//                 backgroundColor: Colors.green[50],
//                 child: Icon(
//                   getCategoryIcon(request.category),
//                   color: Colors.green[800],
//                 ),
//               ),
//               const SizedBox(width: 16),
//
//               // --- Content ---
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       request.title,
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "To: ${request.toCity}",
//                       style: TextStyle(color: Colors.grey[600], fontSize: 13),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "\$${request.budget}",
//                       style: const TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // --- Type Tag and Username ---
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   _buildTypeTag(request.requestType),
//                   const SizedBox(height: 8),
//                   Text(
//                     // FIXED: Changed customerUsername to customerName to match model
//                     "@${request.customerName}",
//                     style: const TextStyle(fontSize: 10, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTypeTag(String type) {
//     bool isBuy = type == "BUY_TRANSPORT";
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: isBuy ? Colors.orange[50] : Colors.blue[50],
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: isBuy ? Colors.orange[200]! : Colors.blue[200]!),
//       ),
//       child: Text(
//         isBuy ? "Buy & Ship" : "Ship Only",
//         style: TextStyle(
//           color: isBuy ? Colors.orange[800] : Colors.blue[800],
//           fontSize: 10,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../models/Customer.dart';

class CustomerRequestCard extends StatelessWidget {
  final CustomerRequest request;
  final VoidCallback onTap;

  const CustomerRequestCard({super.key, required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color accentGold = Color(0xFFECAE0B);
    const Color brandGreen = Color(0xFF089348);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: request.images.isNotEmpty
                    ? Image.network(
                  request.images[0],
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 15),
              // Request Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            request.category,
                            style: const TextStyle(color: accentGold, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          "\$${request.budget}",
                          style: const TextStyle(color: brandGreen, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      request.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A1A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.swap_horiz, size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          "${request.fromCity} to ${request.toCity}",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: Colors.grey[50],
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );
  }
}