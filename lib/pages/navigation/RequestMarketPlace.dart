import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skyporters/models/Customer.dart';
import 'dart:convert';
import 'package:skyporters/utils/api_constants.dart';
// Note: Changed the import to match your standard naming

import '../../widgets/customer_request_card.dart';
import '../RequestDetailPage.dart';
import '../post_request_page.dart';

class RequestMarketplacePage extends StatefulWidget {
  const RequestMarketplacePage({super.key});

  @override
  State<RequestMarketplacePage> createState() => _RequestMarketplacePageState();
}

class _RequestMarketplacePageState extends State<RequestMarketplacePage> {
  String query = "";
  List<CustomerRequest> allRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => isLoading = true);
    try {
      // Updated to match the new Django URL registration
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/customer-requests/"),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        setState(() {
          allRequests = body
              .map((dynamic item) => CustomerRequest.fromJson(item))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load requests");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching requests: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error connecting to server: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Updated filter to use 'toCity' from your final model
    final filtered = allRequests
        .where((r) =>
            r.toCity.toLowerCase().contains(query.toLowerCase()) ||
            r.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Requests"),
        actions: [
          IconButton(
            onPressed: _fetchRequests, 
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearch(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              query.isEmpty ? "No active requests" : "No results for '$query'",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchRequests,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80), // Space for FAB
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => CustomerRequestCard(
                            request: filtered[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RequestDetailPage(request: filtered[index]),
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'request_fab',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostRequestPage()),
          );
          // If the post was successful, result might be true
          _fetchRequests();
        },
        label: const Text("Request Item"),
        icon: const Icon(Icons.add_shopping_cart),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (v) => setState(() => query = v),
        decoration: InputDecoration(
          hintText: "Search by destination or item name...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}