import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skyporters/models/Trip.dart';
import 'package:skyporters/pages/TravelDetailsPage.dart';
import 'package:skyporters/utils/api_constants.dart';
import 'package:skyporters/widgets/passenger_card.dart';

class TripList extends StatefulWidget {
  const TripList({super.key});

  @override
  State<TripList> createState() => _TripListState();
}

class _TripListState extends State<TripList> {
  List<Trip> trips = [];
  bool isLoading = true;
  String query = "";

  // Defining the brand palette locally for consistency
  final Color primaryNavy = const Color(0xFF1A1A1A); // Matching the Card Footer
  final Color accentGold = const Color(0xFFECAE0B);  // Matching Departure
  final Color brandGreen = const Color(0xFF089348);  // Matching Arrival

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

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
        throw Exception("Status: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text("Network Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light grey background makes the white cards "pop"
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: primaryNavy,
        title: const Text(
            "Marketplace",
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24)
        ),
        actions: [
          IconButton(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white)
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: accentGold))
                : _buildTripsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      decoration: BoxDecoration(
        color: primaryNavy,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              "Find a traveler",
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          TextField(
            onChanged: (v) => setState(() => query = v),
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: "Enter destination city...",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
              prefixIcon: Icon(Icons.search_rounded, color: accentGold),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            // Using a colored icon for empty state
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
              child: Icon(Icons.map_outlined, size: 60, color: Colors.grey[400]),
            ),
            const SizedBox(height: 20),
            Text(
                "No routes found",
                style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.w900)
            ),
            const SizedBox(height: 8),
            TextButton.icon(
                onPressed: () => setState(() => query = ""),
                icon: Icon(Icons.backspace_outlined, size: 16, color: brandGreen),
                label: Text("Clear Search", style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold))
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: brandGreen,
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 20),
        itemCount: filteredTrips.length,
        itemBuilder: (context, index) {
          return PassengerCard(
            trip: filteredTrips[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TravelDetailsPage(trip: filteredTrips[index])),
              );
            },
          );
        },
      ),
    );
  }
}