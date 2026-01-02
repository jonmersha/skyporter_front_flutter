import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyporters/models/travler_product.dart';
import 'package:skyporters/utils/api_constants.dart';


class ProductDetailsPage extends StatefulWidget {
  final TravelerProduct product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _activeImageIndex = 0;
  final storage = const FlutterSecureStorage();
  bool _isSending = false;

  // --- API INTEGRATION: SEND ENQUIRY ---
  Future<void> _sendProductEnquiry(BuildContext context) async {
    setState(() => _isSending = true);
    try {
      String? token = await storage.read(key: 'access');
      if (token == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please login to request items")),
          );
        }
        return;
      }

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
        headers: {
          ...ApiConstants.authHeader(token),
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "receiver": widget.product.travelerId, // Assuming travelerId is in model
          "product": widget.product.id,
          "message": "Hi ${widget.product.travelerName}, I am interested in buying the ${widget.product.name} you listed.",
        }),
      );

      if (response.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Request Sent! Check your Inbox for updates."), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      debugPrint("Enquiry Error: $e");
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceSection(),
                  const SizedBox(height: 15),
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildCategoryBadge(widget.product.category),
                  const SizedBox(height: 25),
                  _buildInfoGrid(),
                  const SizedBox(height: 30),
                  const Text(
                    "Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.product.description,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        SizedBox(
          height: 380,
          child: PageView.builder(
            itemCount: widget.product.imageUrls.length,
            onPageChanged: (index) => setState(() => _activeImageIndex = index),
            itemBuilder: (context, index) => Image.network(
              widget.product.imageUrls[index],
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.product.imageUrls.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _activeImageIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _activeImageIndex == index ? Colors.white : Colors.white54,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "\$${widget.product.totalPrice}",
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const Text("Total (Item + Reward)", style: TextStyle(fontSize: 12, color: Colors.green)),
            ],
          ),
          const Icon(Icons.verified_user, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Chip(
      label: Text(category),
      backgroundColor: Colors.indigo[50],
      labelStyle: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
      side: BorderSide.none,
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        _infoCard("Item Cost", "\$${widget.product.price}", Icons.shopping_cart_outlined),
        const SizedBox(width: 12),
        _infoCard("Traveler Profit", "\$${widget.product.expectedReward}", Icons.card_giftcard),
      ],
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: _isSending ? null : () => _sendProductEnquiry(context),
        child: _isSending 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("SEND ENQUIRY TO TRAVELER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}