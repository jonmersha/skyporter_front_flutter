// import 'package:flutter/material.dart';
// import '../models/shipment_model.dart';
//
// class ShipmentDetailPage extends StatelessWidget {
//   final Shipment shipment;
//   const ShipmentDetailPage({super.key, required this.shipment});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Tracking ${shipment.flightNo}")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const Icon(Icons.local_shipping, size: 80, color: Colors.indigo),
//             const SizedBox(height: 20),
//             Text(shipment.itemDescription, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//             const Divider(),
//             ListTile(title: const Text("Status"), trailing: Text(shipment.status)),
//             ListTile(title: const Text("Collect Payment"), trailing: Text("\$${shipment.codAmount}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
//             const Spacer(),
//             if (shipment.status == "Landed")
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
//                 onPressed: () {}, // Action for OTP entry
//                 child: const Text("Verify Handover OTP"),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }