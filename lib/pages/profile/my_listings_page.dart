import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Models
import 'package:skyporters/models/Trip.dart';
import 'package:skyporters/models/travler_product.dart';
import 'package:skyporters/models/Customer.dart';

// Utils & Widgets
import 'package:skyporters/utils/api_constants.dart';
import 'package:skyporters/widgets/passenger_card.dart';
import 'package:skyporters/widgets/product_slider.dart';
import 'package:skyporters/widgets/customer_request_card.dart';

class CustomerActivityList extends StatefulWidget {
  const CustomerActivityList({super.key});

  @override
  State<CustomerActivityList> createState() => _CustomerActivityListState();
}

class _CustomerActivityListState extends State<CustomerActivityList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final storage = const FlutterSecureStorage();

  // Skyport Brand Palette
  final Color primaryDark = const Color(0xFF1A1A1A);
  final Color accentGold = const Color(0xFFECAE0B);
  final Color brandGreen = const Color(0xFF089348);

  List<Trip> myTrips = [];
  List<TravelerProduct> myProducts = [];
  List<CustomerRequest> myRequests = [];
  List<dynamic> myDeals = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchMyActivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        http.get(Uri.parse("${ApiConstants.baseUrl}/api/customer-requests/me/"), headers: headers),
        http.get(Uri.parse("${ApiConstants.baseUrl}/api/deals/"), headers: headers),
      ]);

      if (mounted) {
        setState(() {
          myTrips = (jsonDecode(results[0].body) as List).map((i) => Trip.fromJson(i)).toList();
          myProducts = (jsonDecode(results[1].body) as List).map((i) => TravelerProduct.fromJson(i)).toList();
          myRequests = (jsonDecode(results[2].body) as List).map((i) => CustomerRequest.fromJson(i)).toList();
          myDeals = jsonDecode(results[3].body);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load activity: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "MY ACTIVITY",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: accentGold,
          indicatorWeight: 3,
          labelColor: accentGold,
          unselectedLabelColor: Colors.grey[400],
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          tabs: const [
            Tab(text: "TRIPS", icon: Icon(Icons.flight_takeoff, size: 20)),
            Tab(text: "PRODUCTS", icon: Icon(Icons.sell_outlined, size: 20)),
            Tab(text: "REQUESTS", icon: Icon(Icons.shopping_bag_outlined, size: 20)),
            Tab(text: "DEALS", icon: Icon(Icons.handshake_outlined, size: 20)),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: accentGold))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildRefreshWrapper(_buildTripsList()),
          _buildRefreshWrapper(_buildProductsGrid()),
          _buildRefreshWrapper(_buildRequestsList()),
          _buildRefreshWrapper(_buildDealsList()),
        ],
      ),
    );
  }

  Widget _buildRefreshWrapper(Widget child) {
    return RefreshIndicator(
      onRefresh: _fetchMyActivity,
      color: accentGold,
      child: child,
    );
  }

  Widget _buildTripsList() {
    if (myTrips.isEmpty) return _buildEmpty("No trips posted yet.");
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: myTrips.length,
      itemBuilder: (context, index) => PassengerCard(
        trip: myTrips[index],
        onTap: () {}, // Navigate to edit or detail
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (myProducts.isEmpty) return _buildEmpty("No products listed.");
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: myProducts.length,
      itemBuilder: (context, index) => AutoSlidingProductCard(product: myProducts[index]),
    );
  }

  Widget _buildRequestsList() {
    if (myRequests.isEmpty) return _buildEmpty("You haven't requested items.");
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: myRequests.length,
      itemBuilder: (context, index) => CustomerRequestCard(
        request: myRequests[index],
        onTap: () {},
      ),
    );
  }

  Widget _buildDealsList() {
    if (myDeals.isEmpty) return _buildEmpty("No active deals found.");
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: myDeals.length,
      itemBuilder: (context, index) {
        final deal = myDeals[index];
        final bool isCompleted = deal['status'] == 'COMPLETED';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            title: Text("Order #${deal['id']}", style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text("Final Price: \$${deal['final_price']}",
                style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isCompleted ? brandGreen.withOpacity(0.1) : accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                deal['status'].toString().toUpperCase(),
                style: TextStyle(
                  color: isCompleted ? brandGreen : Colors.orange[800],
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(msg, style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}