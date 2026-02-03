import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Models
import 'package:skyporters/models/Customer.dart';
import 'package:skyporters/models/travler_product.dart';

// Utils & Pages
import 'package:skyporters/utils/api_constants.dart';
import 'package:skyporters/pages/RequestDetailPage.dart';
import 'package:skyporters/pages/post_request_page.dart';

// Widgets
import 'package:skyporters/widgets/customer_request_card.dart';
import 'package:skyporters/widgets/product_slider.dart'; // Ensure AutoSlidingProductCard is here

class RequestMarketplacePage extends StatefulWidget {
  const RequestMarketplacePage({super.key});

  @override
  State<RequestMarketplacePage> createState() => _RequestMarketplacePageState();
}

class _RequestMarketplacePageState extends State<RequestMarketplacePage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  String query = "";
  bool isLoading = true;

  List<CustomerRequest> allRequests = [];
  List<TravelerProduct> travelerItems = [];

  @override
  void initState() {
    super.initState();
    // length: 2 (Shipping Requests and Traveler Offers)
    _tabController = TabController(length: 2, vsync: this);
    _fetchAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Fetches data for both tabs simultaneously
  Future<void> _fetchAllData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final results = await Future.wait([
        http.get(Uri.parse("${ApiConstants.baseUrl}/api/customer-requests/")),
        http.get(Uri.parse("${ApiConstants.baseUrl}/api/traveler-products/")),
      ]);

      if (results[0].statusCode == 200 && results[1].statusCode == 200) {
        final List requestBody = jsonDecode(results[0].body);
        final List productBody = jsonDecode(results[1].body);

        if (mounted) {
          setState(() {
            allRequests = requestBody.map((item) => CustomerRequest.fromJson(item)).toList();
            travelerItems = productBody.map((item) => TravelerProduct.fromJson(item)).toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sync Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Primary theme color for consistent UI
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Marketplace", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _fetchAllData, icon: const Icon(Icons.refresh_rounded))
        ],
        bottom: TabBar(
          controller: _tabController,
          // FIX: Explicitly setting colors so text and icons are visible
          labelColor: Colors.white,            // Active tab text/icon
          unselectedLabelColor: Colors.white70, // Inactive tab text/icon
          indicatorColor: Colors.white,        // Bottom line color
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Shipping", icon: Icon(Icons.local_shipping_outlined)),
            Tab(text: "Shop", icon: Icon(Icons.shopping_bag_outlined)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchHeader(primaryColor),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsList(),
                _buildTravelerOffersGrid(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PostRequestPage()),
        ).then((_) => _fetchAllData()),
        label: const Text("Request Item"),
        icon: const Icon(Icons.add_shopping_cart),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  /// Search bar with primary color background for better UI flow
  Widget _buildSearchHeader(Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: bgColor,
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

  /// Tab 1: Shipping Requests List
  Widget _buildRequestsList() {
    final filtered = allRequests.where((r) =>
    r.toCity.toLowerCase().contains(query.toLowerCase()) ||
        r.title.toLowerCase().contains(query.toLowerCase())).toList();

    if (filtered.isEmpty) return _buildEmptyState(Icons.search_off, "No shipping requests found");

    return RefreshIndicator(
      onRefresh: _fetchAllData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
        itemCount: filtered.length,
        itemBuilder: (context, index) => CustomerRequestCard(
          request: filtered[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RequestDetailPage(request: filtered[index])),
          ),
        ),
      ),
    );
  }

  /// Tab 2: Traveler Offers Grid
  Widget _buildTravelerOffersGrid() {
    final filtered = travelerItems.where((p) =>
        p.name.toLowerCase().contains(query.toLowerCase())).toList();

    if (filtered.isEmpty) return _buildEmptyState(Icons.inventory_2_outlined, "No items in shop");

    return RefreshIndicator(
      onRefresh: _fetchAllData,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75, // Adjust based on your card height
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) => AutoSlidingProductCard(product: filtered[index]),
      ),
    );
  }

  /// Common empty state widget
  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }
}