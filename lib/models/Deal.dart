class Deal {
  final int id;
  final int customerId;
  final String customerName;
  final int travelerId;
  final String travelerName;
  final int? tripId;
  final int? productId;
  final int? requestId;
  final String status; // PENDING, COMPLETED, etc.
  final String statusDisplay; // The human-readable version from Django
  final double finalPrice;
  final DateTime updatedAt;

  Deal({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.travelerId,
    required this.travelerName,
    this.tripId,
    this.productId,
    this.requestId,
    required this.status,
    required this.statusDisplay,
    required this.finalPrice,
    required this.updatedAt,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'] ?? 0,
      customerId: json['customer'] ?? 0,
      customerName: json['customer_name'] ?? "Unknown",
      travelerId: json['traveler'] ?? 0,
      travelerName: json['traveler_name'] ?? "Unknown",
      tripId: json['trip'],
      productId: json['product'],
      requestId: json['request'],
      status: json['status'] ?? "PENDING",
      statusDisplay: json['status_display'] ?? "Pending",
      finalPrice: double.tryParse(json['final_price'].toString()) ?? 0.0,
      updatedAt: DateTime.parse(json['updated_at'] ?? "2026-01-01"),
    );
  }
}