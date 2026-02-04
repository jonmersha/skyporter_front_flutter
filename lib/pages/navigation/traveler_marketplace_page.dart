import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skyporters/models/Trip.dart';
import 'package:skyporters/pages/TravelDetailsPage.dart';
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

  /// Fetches available trips from the Django backend
  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/trips/"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List tripBody = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            trips = tripBody.map((item) => Trip.fromJson(item)).toList();
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load trips: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection Error: $e")),
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
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
            "Traveler Marketplace",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        actions: [
          IconButton(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white)
          )
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
      // FloatingActionButton removed as per request
    );
  }

  /// Search bar to filter trips by city
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: TextField(
        onChanged: (v) => setState(() => query = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Where are you sending to?",
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// List of trips filtered by the search query
  Widget _buildTripsList() {
    final filteredTrips = trips.where((t) =>
    t.destinationCity.toLowerCase().contains(query.toLowerCase()) ||
        t.departureCity.toLowerCase().contains(query.toLowerCase())
    ).toList();

    if (filteredTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flight_takeoff_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
                "No travelers found for this route",
                style: TextStyle(color: Colors.grey[600], fontSize: 16)
            ),
            TextButton(
                onPressed: () => setState(() => query = ""),
                child: const Text("Clear Search")
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        itemCount: filteredTrips.length,
        itemBuilder: (context, index) {
          final trip = filteredTrips[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PassengerCard(
              trip: trip,
              onTap: () {
                // Navigates to the details page to start the Enquiry process
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TravelDetailsPage(trip: trip)
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}