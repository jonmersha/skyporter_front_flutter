import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// Models
import 'package:skyporters/models/Trip.dart';
import 'package:skyporters/models/travler_product.dart';
import 'package:skyporters/models/Customer.dart'; // Ensure CustomerRequest model is imported

// Utils & Widgets
import 'package:skyporters/utils/api_constants.dart';
import 'package:skyporters/widgets/passenger_card.dart';
import 'package:skyporters/widgets/product_slider.dart';
import 'package:skyporters/widgets/customer_request_card.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final storage = const FlutterSecureStorage();

  List<Trip> myTrips = [];
  List<TravelerProduct> myProducts = [];
  List<CustomerRequest> myRequests = []; // Added this
  List<dynamic> myDeals = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Length changed to 4 to accommodate "My Requests"
    _tabController = TabController(length: 4, vsync: this);
    _fetchMyActivity();
  }

  Future<void> _fetchMyActivity() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    String? token = await storage.read(key: 'access');
    final headers = ApiConstants.authHeader(token ?? "");

    try {
      final results = await Future.wait([
        http.get(Uri.parse("${ApiConstants.baseUrl}/api/trips/me/"), headers: headers),
        http.get(Uri.parse("${ApiConstants.baseUrl}/api/traveler-products/me/"), headers: headers),
        http.get(Uri.parse("${ApiConstants.baseUrl}/api/customer-requests/me/"), headers: headers), // New Call
        http.get(Uri.parse("${ApiConstants.baseUrl}/api/deals/"), headers: headers),
      ]);

      if (mounted) {
        setState(() {
          myTrips = (jsonDecode(results[0].body) as List).map((i) => Trip.fromJson(i)).toList();
          myProducts = (jsonDecode(results[1].body) as List).map((i) => TravelerProduct.fromJson(i)).toList();
          myRequests = (jsonDecode(results[2].body) as List).map((i) => CustomerRequest.fromJson(i)).toList(); // New Mapping
          myDeals = jsonDecode(results[3].body);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Activity"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Recommended since we now have 4 tabs
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Trips", icon: Icon(Icons.flight)),
            Tab(text: "Products", icon: Icon(Icons.sell)),
            Tab(text: "Requests", icon: Icon(Icons.shopping_bag)), // Added Tab
            Tab(text: "Deals", icon: Icon(Icons.handshake)),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildTripsList(),
          _buildProductsGrid(),
          _buildRequestsList(), // Added View
          _buildDealsList(),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    if (myRequests.isEmpty) return _buildEmpty("You haven't requested any items.");
    return RefreshIndicator(
      onRefresh: _fetchMyActivity,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: myRequests.length,
        itemBuilder: (context, index) => CustomerRequestCard(
          request: myRequests[index],
          onTap: () { /* Detail view logic */ },
        ),
      ),
    );
  }

  // ... (Keeping _buildTripsList, _buildProductsGrid, _buildDealsList from previous implementation)

  Widget _buildEmpty(String msg) => Center(child: Text(msg, style: const TextStyle(color: Colors.grey)));

  Widget _buildTripsList() {
    if (myTrips.isEmpty) return _buildEmpty("No trips posted.");
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: myTrips.length,
        itemBuilder: (context, index) => PassengerCard(trip: myTrips[index], onTap: () {  },));
  }

  Widget _buildProductsGrid() {
    if (myProducts.isEmpty) return _buildEmpty("No products listed.");
    return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 10,
        ),
        itemCount: myProducts.length,
        itemBuilder: (context, index) => AutoSlidingProductCard(product: myProducts[index]));
  }

  Widget _buildDealsList() {
    if (myDeals.isEmpty) return _buildEmpty("No active deals.");
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: myDeals.length,
      itemBuilder: (context, index) {
        final deal = myDeals[index];
        return Card(
          child: ListTile(
            title: Text("Deal #${deal['id']} - ${deal['status']}"),
            subtitle: Text("Price: \$${deal['final_price']}"),
          ),
        );
      },
    );
  }
}