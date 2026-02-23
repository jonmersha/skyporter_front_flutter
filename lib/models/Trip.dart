class Trip {
  final int id;
  final int travelerId;
  final String travelerFullName; // Renamed for clarity
  final String? travelerPhone;
  final String travelerEmail;
  final String departureCity;
  final String destinationCity;
  final DateTime departureDate;
  final DateTime arrivalDate;
  final double laptopFee;
  final double mobileFee;
  final double cosmeticFee;
  final double otherFee;
  final bool isActive;

  Trip({
    required this.id,
    required this.travelerId,
    required this.travelerFullName,
    this.travelerPhone,
    required this.travelerEmail,
    required this.departureCity,
    required this.destinationCity,
    required this.departureDate,
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
      // Matches the SerializerMethodField 'traveler_full_name' from Django
      travelerFullName: json['traveler_full_name'] ?? "Unknown Traveler",
      travelerPhone: json['traveler_phone'],
      travelerEmail: json['traveler_email'] ?? "",
      departureCity: json['departure_city'] ?? "",
      destinationCity: json['destination_city'] ?? "",

      departureDate: json['departure_date'] != null
          ? DateTime.parse(json['departure_date'])
          : DateTime.now(),

      arrivalDate: json['arrival_date'] != null
          ? DateTime.parse(json['arrival_date'])
          : DateTime.now(),

      // Using tryParse for safety with decimal fields
      laptopFee: double.tryParse(json['laptop_fee']?.toString() ?? "0.0") ?? 0.0,
      mobileFee: double.tryParse(json['mobile_fee']?.toString() ?? "0.0") ?? 0.0,
      cosmeticFee: double.tryParse(json['cosmetic_fee']?.toString() ?? "0.0") ?? 0.0,
      otherFee: double.tryParse(json['other_fee']?.toString() ?? "0.0") ?? 0.0,
      isActive: json['is_active'] ?? true,
    );
  }
}