class TravelerProduct {
  final int id;
  final int travelerId; // Maps to "traveler": 1
  final String travelerName;
  final String name;
  final String description;
  final String category;
  final double price;
  final double expectedReward;
  final double totalPrice; // Maps to 110 (num)
  final DateTime arrivalDate;
  final DateTime expirationTime;
  final List<String> imageUrls;

  TravelerProduct({
    required this.id,
    required this.travelerId,
    required this.travelerName,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.expectedReward,
    required this.totalPrice,
    required this.arrivalDate,
    required this.expirationTime,
    required this.imageUrls,
  });

  factory TravelerProduct.fromJson(Map<String, dynamic> json) {
    var imageList = json['images'] as List? ?? [];

    return TravelerProduct(
      id: json['id'] ?? 0,
      travelerId: json['traveler'] ?? 0,
      travelerName: json['traveler_name'] ?? "Unknown",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      category: json['category'] ?? "OTHER",
      // Handling numbers safely whether they come as int or double
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      expectedReward: (json['expected_reward'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      arrivalDate: DateTime.parse(json['arrival_date'] ?? "2026-01-01"),
      expirationTime:
          DateTime.parse(json['expiration_time'] ?? "2026-01-01T00:00:00Z"),
      imageUrls: imageList.map((img) => img['image'].toString()).toList(),
    );
  }
}
