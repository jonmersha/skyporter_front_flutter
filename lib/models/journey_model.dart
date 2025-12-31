class Journey {
  final String id;
  final String personName;
  final String contactInfo;
  final String flightNo;
  final String route;
  final String departureTime;
  final String arrivalTime;
  final double totalLuggage;
  final double pricePerKg;
  final String status;

  Journey({
    required this.id,
    required this.personName,
    required this.contactInfo,
    required this.flightNo,
    required this.route,
    required this.departureTime,
    required this.arrivalTime,
    required this.totalLuggage,
    required this.pricePerKg,
    this.status = "Available",
  });
}