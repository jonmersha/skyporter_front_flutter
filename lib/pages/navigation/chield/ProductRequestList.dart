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
import 'package:skyporters/pages/profile/post_request_page.dart';

// Widgets
import 'package:skyporters/widgets/customer_request_card.dart';
import 'package:skyporters/widgets/product_slider.dart';

class ProductRequestList extends StatefulWidget {
  const ProductRequestList({super.key});

  @override
  State<ProductRequestList> createState() => _ProductRequestListState();
}

class _ProductRequestListState extends State<ProductRequestList>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  String query = "";
  bool isLoading = true;

  List<CustomerRequest> allRequests = [];
  List<TravelerProduct> travelerItems = [];

  // Theme Palette
  final Color primaryDark = const Color(0xFF1A1A1A); // Midnight Charcoal
  final Color accentGold = const Color(0xFFECAE0B);  // Golden Yellow
  final Color brandGreen = const Color(0xFF089348);  // Emerald Green

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          SnackBar(backgroundColor: Colors.redAccent, content: Text("Sync Error: $e")),
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
        backgroundColor: primaryDark,
        title: const Text("Marketplace",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white)),
        centerTitle: false,
        actions: [
          IconButton(onPressed: _fetchAllData,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white))
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: accentGold,
          unselectedLabelColor: Colors.white54,
          indicatorColor: accentGold,
          indicatorWeight: 4,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          tabs: const [
            Tab(text: "SHIPPING", icon: Icon(Icons.local_shipping_rounded)),
            Tab(text: "SHOP", icon: Icon(Icons.storefront_rounded)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: brandGreen))
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
          MaterialPageRoute(builder: (_) => const PostProductRequest()),
        ).then((_) => _fetchAllData()),
        label: const Text("NEW REQUEST", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        icon: const Icon(Icons.add_circle_outline),
        backgroundColor: brandGreen,
        elevation: 6,
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: TextField(
        onChanged: (v) => setState(() => query = v),
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: "Search destinations or items...",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: accentGold),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    final filtered = allRequests.where((r) =>
    r.toCity.toLowerCase().contains(query.toLowerCase()) ||
        r.title.toLowerCase().contains(query.toLowerCase())).toList();

    if (filtered.isEmpty) return _buildEmptyState(Icons.manage_search_rounded, "No shipping requests found");

    return RefreshIndicator(
      color: brandGreen,
      onRefresh: _fetchAllData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 80),
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

  Widget _buildTravelerOffersGrid() {
    final filtered = travelerItems.where((p) =>
        p.name.toLowerCase().contains(query.toLowerCase())).toList();

    if (filtered.isEmpty) return _buildEmptyState(Icons.inventory_2_rounded, "No items in shop");

    return RefreshIndicator(
      color: brandGreen,
      onRefresh: _fetchAllData,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) => AutoSlidingProductCard(product: filtered[index]),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: Icon(icon, size: 50, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}