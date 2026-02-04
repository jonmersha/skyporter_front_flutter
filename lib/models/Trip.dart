class Trip {
  final int id;
  final int travelerId;
  final String travelerName;
  final String? travelerPhone; // Nullable because JSON shows it can be null
  final String travelerEmail;
  final String departureCity;
  final String destinationCity;
  final DateTime arrivalDate;
  final double laptopFee;
  final double mobileFee;
  final double cosmeticFee;
  final double otherFee;
  final bool isActive;

  Trip({
    required this.id,
    required this.travelerId,
    required this.travelerName,
    this.travelerPhone,
    required this.travelerEmail,
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
      travelerName: json['traveler_name'] ?? "Unknown",
      travelerPhone: json['traveler_phone'], // Correctly handle null
      travelerEmail: json['traveler_email'] ?? "",
      departureCity: json['departure_city'] ?? "",
      destinationCity: json['destination_city'] ?? "",
      // Use tryParse or a fallback for date parsing
      arrivalDate: json['arrival_date'] != null
          ? DateTime.parse(json['arrival_date'])
          : DateTime.now(),
      // Use double.tryParse for safety against string numbers
      laptopFee: double.tryParse(json['laptop_fee'].toString()) ?? 0.0,
      mobileFee: double.tryParse(json['mobile_fee'].toString()) ?? 0.0,
      cosmeticFee: double.tryParse(json['cosmetic_fee'].toString()) ?? 0.0,
      // FIXED: Mapping from 'other_fee' instead of 'other_fee_base'
      otherFee: double.tryParse(json['other_fee'].toString()) ?? 0.0,
      isActive: json['is_active'] ?? true,
    );
  }
}