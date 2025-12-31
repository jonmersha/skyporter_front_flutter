class ProductRequest {
  final String id;
  final String senderName;
  final String productName;
  final String destination; // Where it needs to go
  final String purchaseLocation; // Where it is bought (e.g., "Dubai Duty Free")
  final double weight;
  final double purchasePrice; // 0 if sender already has the item
  final double reward; // What the traveler earns
  final String contactInfo;
  final bool isPurchaseRequest; // True if traveler needs to buy it

  ProductRequest({
    required this.id,
    required this.senderName,
    required this.productName,
    required this.destination,
    required this.purchaseLocation,
    required this.weight,
    required this.purchasePrice,
    required this.reward,
    required this.contactInfo,
    required this.isPurchaseRequest,
  });
}