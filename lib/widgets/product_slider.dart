import 'dart:async';
import 'package:flutter/material.dart';
import 'package:skyporters/models/travler_product.dart';


class AutoSlidingProductCard extends StatefulWidget {
  final TravelerProduct product;
  const AutoSlidingProductCard({super.key, required this.product});

  @override
  State<AutoSlidingProductCard> createState() => _AutoSlidingProductCardState();
}

class _AutoSlidingProductCardState extends State<AutoSlidingProductCard> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    
    // Auto-slide only if there are multiple images
    if (widget.product.imageUrls.length > 1) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % widget.product.imageUrls.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // Ensures image corners are rounded
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Image Section ---
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.product.imageUrls.length,
                  onPageChanged: (index) => _currentPage = index,
                  itemBuilder: (context, index) => Image.network(
                    widget.product.imageUrls[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => 
                        Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                  ),
                ),
                // Category Tag overlay
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.product.category,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // --- Info Section ---
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${widget.product.totalPrice.toStringAsFixed(2)}", // Using totalPrice from model
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Arrives: ${widget.product.arrivalDate.toString().split(' ')[0]}",
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey[400]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}