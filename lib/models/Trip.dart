class Trip {
  final int id;
  final int travelerId;
  final String travelerName;
  final String departureCity;
  final String destinationCity;
  final DateTime arrivalDate;
  final double laptopFee;
  final double mobileFee;
  final double cosmeticFee;
  final double otherFee; // Mapped from other_fee_base
  final bool isActive;

  Trip({
    required this.id,
    required this.travelerId,
    required this.travelerName,
    required this.departureCity,
    required this.destinationCity,
    required this.arrivalDate,
    required this.laptopFee,
    required this.mobileFee,
    required this.cosmeticFee,
    required this.otherFee,
    required this.isActive,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? 0,
      travelerId: json['traveler'] ?? 0,
      travelerName: json['traveler_name'] ?? "Unknown Traveler",
      departureCity: json['departure_city'] ?? "",
      destinationCity: json['destination_city'] ?? "",
      arrivalDate: DateTime.parse(json['arrival_date'] ?? "2026-01-01"),
      laptopFee: double.tryParse(json['laptop_fee'].toString()) ?? 0.0,
      mobileFee: double.tryParse(json['mobile_fee'].toString()) ?? 0.0,
      cosmeticFee: double.tryParse(json['cosmetic_fee'].toString()) ?? 0.0,
      otherFee: double.tryParse(json['other_fee_base'].toString()) ?? 0.0,
      isActive: json['is_active'] ?? true,
    );
  }
}
