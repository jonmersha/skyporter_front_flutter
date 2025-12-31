import 'package:flutter/material.dart';
import '../models/customer_request_model.dart';

class CustomerRequestCard extends StatelessWidget {
  final CustomerRequest request;
  final VoidCallback onTap; // Add this line

  const CustomerRequestCard({
    super.key,
    required this.request,
    required this.onTap, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[50],
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap, // Bind the callback here
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.shopping_bag, color: Colors.white, size: 20),
          ),
          title: Text(request.productName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("To: ${request.to} • Reward: \$${request.deliveryReward}"),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: request.isPurchaseRequired ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              request.isPurchaseRequired ? "Buy" : "Ship",
              style: TextStyle(
                  color: request.isPurchaseRequired ? Colors.orange[800] : Colors.blue[800],
                  fontSize: 10,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ),
    );
  }
}