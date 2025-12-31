class CustomerRequest {
  final String id, senderName, productName, from, to, contact;
  final double itemPrice, deliveryReward, weight;
  final bool isPurchaseRequired;

  CustomerRequest({
    required this.id, required this.senderName, required this.productName,
    required this.from, required this.to, required this.contact,
    required this.itemPrice, required this.deliveryReward, required this.weight,
    required this.isPurchaseRequired,
  });
}