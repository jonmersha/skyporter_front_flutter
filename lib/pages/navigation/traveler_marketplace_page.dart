import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:skyporters/models/trip.dart'; 
import 'package:skyporters/models/travler_product.dart';
import 'package:skyporters/pages/TravelDetailsPage.dart';
import 'package:skyporters/pages/passenger/post_trip_page.dart';
import 'package:skyporters/pages/travler_product.dart'; // Contains PostProductPage
import 'package:skyporters/utils/api_constants.dart';
import 'package:skyporters/widgets/passenger_card.dart';
import 'package:skyporters/widgets/product_slider.dart';

class TravelerMarketplacePage extends StatefulWidget {
  const TravelerMarketplacePage({super.key});

  @override
  State<TravelerMarketplacePage> createState() => _TravelerMarketplacePageState();
}

class _TravelerMarketplacePageState extends State<TravelerMarketplacePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Trip> trips = [];
  List<TravelerProduct> products = [];
  bool isLoading = true;
  String query = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final results = await Future.wait([
        http.get(Uri.parse("${ApiConstants.baseUrl}/api/trips/")),
        http.get(Uri.parse("${ApiConstants.baseUrl}/api/traveler-products/")),
      ]);

      if (results[0].statusCode == 200 && results[1].statusCode == 200) {
        final List tripBody = jsonDecode(results[0].body);
        final List prodBody = jsonDecode(results[1].body);

        if (mounted) {
          setState(() {
            trips = tripBody.map((item) => Trip.fromJson(item)).toList();
            products = prodBody.map((item) => TravelerProduct.fromJson(item)).toList();
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
        title: const Text("Traveler Marketplace", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: _fetchData, icon: const Icon(Icons.refresh_rounded))
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.lightGreenAccent[400],
          indicatorWeight: 4,
          tabs: const [
            Tab(text: "Available Trips", icon: Icon(Icons.explore_outlined)),
            Tab(text: "Traveler Shop", icon: Icon(Icons.shopping_bag_outlined)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTripsList(),
                      _buildProductsGrid(),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: _buildMultiFab(),
    );
  }

  // --- HELPER METHODS ---

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).primaryColor,
      child: TextField(
        onChanged: (v) => setState(() => query = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search destinations or items...",
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

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTripsList() {
    final filteredTrips = trips.where((t) =>
            t.destinationCity.toLowerCase().contains(query.toLowerCase()) ||
            t.departureCity.toLowerCase().contains(query.toLowerCase())).toList();

    if (filteredTrips.isEmpty) {
      return _buildEmptyState(Icons.airplanemode_inactive, "No active journeys found");
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

  Widget _buildProductsGrid() {
    final filteredProds = products.where((p) => 
        p.name.toLowerCase().contains(query.toLowerCase())).toList();

    if (filteredProds.isEmpty) {
      return _buildEmptyState(Icons.inventory_2_outlined, "No items listed for sale");
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 160),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: filteredProds.length,
        itemBuilder: (context, index) => AutoSlidingProductCard(product: filteredProds[index]),
      ),
    );
  }

  Widget _buildMultiFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: "prod_fab",
          onPressed: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const PostProductPage())
          ).then((_) => _fetchData()),
          label: const Text("List Item"),
          icon: const Icon(Icons.sell_outlined),
          backgroundColor: Colors.green[600],
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: "trip_fab",
          onPressed: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const PostTripPage())
          ).then((_) => _fetchData()),
          label: const Text("Post Trip"),
          icon: const Icon(Icons.add_location_alt_outlined),
          backgroundColor: const Color(0xFF1A237E),
        ),
      ],
    );
  }
}