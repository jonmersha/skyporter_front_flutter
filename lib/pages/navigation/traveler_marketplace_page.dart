import 'package:flutter/material.dart';
import 'package:skyporters/pages/post_trip_page.dart';
import '../../models/passenger_post_model.dart';
import '../../widgets/passenger_card.dart';
import '../TravelDetailsPage.dart';

class TravelerMarketplacePage extends StatefulWidget {
  const TravelerMarketplacePage({super.key});

  @override
  State<TravelerMarketplacePage> createState() => _TravelerMarketplacePageState();
}

class _TravelerMarketplacePageState extends State<TravelerMarketplacePage> {
  String query = "";

  // Mock data (replace with API call)
  final List<PassengerPost> travelers = [
    PassengerPost(id: "1", travelerName: "Alex R.", from: "Dubai", to: "Cairo", date: "Jan 10", contact: "123", pricePerKg: 10, laptopFee: 40, smartphoneFee: 20, availableKg: 20),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = travelers.where((t) => t.to.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Available Travelers")),
      body: Column(
        children: [
          _buildSearch(),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) => PassengerCard(
                post: filtered[index],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TravelDetailsPage(post: filtered[index]))),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostTripPage()) // Link fixed here
        ),
        label: const Text("Post My Trip"),
        icon: const Icon(Icons.flight_takeoff),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (v) => setState(() => query = v),
        decoration: InputDecoration(
          hintText: "Where is your item going?",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}