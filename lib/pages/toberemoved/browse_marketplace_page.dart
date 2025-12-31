// import 'package:flutter/material.dart';
// import 'package:skyporters/pages/TravelDetailsPage.dart';
// import '../models/passenger_post_model.dart';
// import '../models/customer_request_model.dart';
// import '../widgets/passenger_card.dart';
// import '../widgets/customer_request_card.dart';
// import 'RequestDetailPage.dart';
//
//
// class BrowseMarketplacePage extends StatefulWidget {
//   const BrowseMarketplacePage({super.key});
//
//   @override
//   State<BrowseMarketplacePage> createState() => _BrowseMarketplacePageState();
// }
//
// class _BrowseMarketplacePageState extends State<BrowseMarketplacePage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String searchQuery = "";
//
//   // --- MOCK DATA: PASSENGER POSTS (Travelers offering space) ---
//   final List<PassengerPost> mockPassengers = [
//     PassengerPost(
//       id: "P1", travelerName: "Alex Rivera", from: "Dubai (DXB)", to: "Cairo (CAI)",
//       date: "Jan 15, 2026", contact: "+971501234567",
//       pricePerKg: 12.0, laptopFee: 50.0, smartphoneFee: 30.0, availableKg: 15.0,
//     ),
//     PassengerPost(
//       id: "P2", travelerName: "Maria Garcia", from: "London (LHR)", to: "New York (JFK)",
//       date: "Jan 18, 2026", contact: "+447712345678",
//       pricePerKg: 15.0, laptopFee: 60.0, smartphoneFee: 40.0, availableKg: 8.0,
//     ),
//   ];
//
//   // --- MOCK DATA: CUSTOMER REQUESTS (Senders needing delivery) ---
//   final List<CustomerRequest> mockRequests = [
//     CustomerRequest(
//       id: "R1", senderName: "Sarah J.", productName: "MacBook Pro M3",
//       from: "Dubai (DXB)", to: "Cairo (CAI)", contact: "+20123456789",
//       itemPrice: 2000.0, deliveryReward: 100.0, weight: 1.6, isPurchaseRequired: true,
//     ),
//     CustomerRequest(
//       id: "R2", senderName: "James Bond", productName: "Organic Spices Pack",
//       from: "Istanbul (IST)", to: "London (LHR)", contact: "+44123456789",
//       itemPrice: 0.0, deliveryReward: 25.0, weight: 2.0, isPurchaseRequired: false,
//     ),
//   ];
//
//   @override
//   void initState() {
//     _tabController = TabController(length: 2, vsync: this);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FD),
//       appBar: AppBar(
//         title: const Text("SkyPorters Market"),
//         centerTitle: true,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           indicatorWeight: 3,
//           tabs: const [
//             Tab(text: "Find Passengers", icon: Icon(Icons.flight_takeoff)),
//             Tab(text: "Find Requests", icon: Icon(Icons.shopping_basket)),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           _buildSearchHeader(),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildPassengerTab(),
//                 _buildRequestTab(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSearchHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: Colors.white,
//       child: TextField(
//         onChanged: (value) => setState(() => searchQuery = value),
//         decoration: InputDecoration(
//           hintText: "Search destination city (e.g. Cairo)...",
//           prefixIcon: const Icon(Icons.location_on, color: Colors.indigo),
//           filled: true,
//           fillColor: Colors.grey[100],
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // --- TAB 1: PASSENGERS LIST ---
//   Widget _buildPassengerTab() {
//     final filtered = mockPassengers.where((p) =>
//         p.to.toLowerCase().contains(searchQuery.toLowerCase())).toList();
//
//     if (filtered.isEmpty) return _buildEmptyState();
//
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       itemCount: filtered.length,
//       itemBuilder: (context, index) => PassengerCard(
//         post: filtered[index],
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => PassengerDetailPage(post: filtered[index])),
//         ),
//       ),
//     );
//   }
//
//   // --- TAB 2: REQUESTS LIST ---
//   Widget _buildRequestTab() {
//     final filtered = mockRequests.where((r) =>
//         r.to.toLowerCase().contains(searchQuery.toLowerCase())).toList();
//
//     if (filtered.isEmpty) return _buildEmptyState();
//
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       itemCount: filtered.length,
//       itemBuilder: (context, index) => CustomerRequestCard(
//         request: filtered[index],
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => RequestDetailPage(request: filtered[index])),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
//           const SizedBox(height: 16),
//           Text("No results found for \"$searchQuery\"",
//               style: TextStyle(color: Colors.grey[600])),
//         ],
//       ),
//     );
//   }
// }