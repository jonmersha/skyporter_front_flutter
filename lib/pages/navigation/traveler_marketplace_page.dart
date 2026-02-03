import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skyporters/models/Trip.dart';
import 'package:skyporters/pages/TravelDetailsPage.dart';
import 'package:skyporters/pages/passenger/post_trip_page.dart';
import 'package:skyporters/utils/api_constants.dart';
import 'package:skyporters/widgets/passenger_card.dart';

class TravelerMarketplacePage extends StatefulWidget {
  const TravelerMarketplacePage({super.key});

  @override
  State<TravelerMarketplacePage> createState() => _TravelerMarketplacePageState();
}

class _TravelerMarketplacePageState extends State<TravelerMarketplacePage> {
  List<Trip> trips = [];
  bool isLoading = true;
  String query = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // Only fetching trips now
      final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/api/trips/"));

      if (response.statusCode == 200) {
        final List tripBody = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            trips = tripBody.map((item) => Trip.fromJson(item)).toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error syncing with Skyporters API: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text("Available Trips", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: _fetchData, icon: const Icon(Icons.refresh_rounded))
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTripsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostTripPage())
        ).then((_) => _fetchData()),
        label: const Text("Post Trip"),
        icon: const Icon(Icons.add_location_alt_outlined),
        backgroundColor: const Color(0xFF1A237E),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).primaryColor,
      child: TextField(
        onChanged: (v) => setState(() => query = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search destinations...",
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTripsList() {
    final filteredTrips = trips.where((t) =>
    t.destinationCity.toLowerCase().contains(query.toLowerCase()) ||
        t.departureCity.toLowerCase().contains(query.toLowerCase())).toList();

    if (filteredTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.airplanemode_inactive, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("No active journeys found", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
        itemCount: filteredTrips.length,
        itemBuilder: (context, index) => PassengerCard(
          trip: filteredTrips[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TravelDetailsPage(trip: filteredTrips[index])),
          ),
        ),
      ),
    );
  }
}