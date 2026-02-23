import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Added
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
  final storage = const FlutterSecureStorage(); // Added
  List<Trip> trips = [];
  bool isLoading = true;
  String query = "";
  String? currentUserId; // Added to track local user

  final Color primaryNavy = const Color(0xFF1A1A1A);
  final Color accentGold = const Color(0xFFECAE0B);
  final Color brandGreen = const Color(0xFF089348);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // 1. Get the current user's ID to filter out their own trips
      currentUserId = await storage.read(key: 'user_id');

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
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryNavy,
        title: const Text("Marketplace",
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24)),
        actions: [
          IconButton(onPressed: _fetchData, icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
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
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: TextField(
        onChanged: (v) => setState(() => query = v),
        decoration: InputDecoration(
          hintText: "Enter destination city...",
          prefixIcon: Icon(Icons.search_rounded, color: accentGold),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildTripsList() {
    // UPDATED FILTER: Exclude trips where travelerId matches currentUserId
    final filteredTrips = trips.where((t) {
      final matchesSearch = t.destinationCity.toLowerCase().contains(query.toLowerCase()) ||
          t.departureCity.toLowerCase().contains(query.toLowerCase());

      // Safety check: Don't show the user's own trips
      final isNotMine = t.travelerId.toString() != currentUserId;

      return matchesSearch && isNotMine;
    }).toList();

    if (filteredTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text("No available trips found",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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