// import 'package:flutter/material.dart';
// import '../models/shipment_model.dart';
// import '../pages/toberemoved/shipment_detail_page.dart';
//
// class ShipmentCard extends StatelessWidget {
//   final Shipment shipment;
//
//   const ShipmentCard({super.key, required this.shipment});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => ShipmentDetailPage(shipment: shipment))
//         ),
//         leading: const Icon(Icons.flight_takeoff, color: Colors.indigo),
//         title: Text("${shipment.flightNo}: ${shipment.itemDescription}"),
//         subtitle: Text("${shipment.origin} ➔ ${shipment.destination}"),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("\$${shipment.codAmount}", style: const TextStyle(fontWeight: FontWeight.bold)),
//             Text(shipment.status, style: TextStyle(color: shipment.status == "Landed" ? Colors.green : Colors.blue, fontSize: 10)),
//           ],
//         ),
//       ),
//     );
//   }
// }