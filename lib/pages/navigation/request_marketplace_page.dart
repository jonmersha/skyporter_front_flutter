import 'package:flutter/material.dart';
import 'package:skyporters/pages/post_request_page.dart';
import '../../models/customer_request_model.dart';
import '../../widgets/customer_request_card.dart';
import '../RequestDetailPage.dart';


class RequestMarketplacePage extends StatefulWidget {
  const RequestMarketplacePage({super.key});

  @override
  State<RequestMarketplacePage> createState() => _RequestMarketplacePageState();
}

class _RequestMarketplacePageState extends State<RequestMarketplacePage> {
  String query = "";

  final List<CustomerRequest> requests = [
    CustomerRequest(id: "R1", senderName: "Sarah", productName: "iPhone 15", from: "Dubai", to: "Cairo", contact: "456", itemPrice: 1000, deliveryReward: 60, weight: 0.5, isPurchaseRequired: true),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = requests.where((r) => r.to.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Item Requests")),
      body: Column(
        children: [
          _buildSearch(),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) => CustomerRequestCard(
                request: filtered[index],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RequestDetailPage(request: filtered[index]))),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostRequestPage()) // Link fixed here
        ),
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
          hintText: "Search requests by destination...",
          prefixIcon: const Icon(Icons.shopping_bag),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}