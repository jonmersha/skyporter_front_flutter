// import 'package:flutter/material.dart';
//
// import '../models/shipment_model.dart';
// import '../services/api_service.dart';
// import '../widgets/shipment_card.dart';
//
// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> {
//   final ApiService _apiService = ApiService();
//   late Future<List<Shipment>> _shipments;
//
//   @override
//   void initState() {
//     super.initState();
//     _shipments = _apiService.fetchMyShipments();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("My Deliveries")),
//       body: FutureBuilder<List<Shipment>>(
//         future: _shipments,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return const Center(child: Text("Error loading data"));
//           } else {
//             return ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) =>
//                   ShipmentCard(shipment: snapshot.data![index]),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
