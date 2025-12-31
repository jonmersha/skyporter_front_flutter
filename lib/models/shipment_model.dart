class Journey {
  final String personName;
  final String contactInfo;
  final String flightNo;
  final String route;
  final String departureTime;
  final String arrivalTime;
  final double totalLuggage;
  final double pricePerKg;

  Journey({
    required this.personName,
    required this.contactInfo,
    required this.flightNo,
    required this.route,
    required this.departureTime,
    required this.arrivalTime,
    required this.totalLuggage,
    required this.pricePerKg,
  });
}
class Shipment {
  final String id;
  final String flightNo;
  final String origin;
  final String destination;
  final String status; // 'In-Transit', 'Landed', 'Pending'
  final String itemDescription;
  final double weight;
  final double codAmount; // Cash on Delivery total
  final bool isBuyAndDeliver;

  Shipment({
    required this.id,
    required this.flightNo,
    required this.origin,
    required this.destination,
    required this.status,
    required this.itemDescription,
    required this.weight,
    required this.codAmount,
    required this.isBuyAndDeliver,
  });

  // Factory to convert API JSON to Model
  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json['id'],
      flightNo: json['flightNo'],
      origin: json['origin'],
      destination: json['destination'],
      status: json['status'],
      itemDescription: json['itemDescription'],
      weight: json['weight'].toDouble(),
      codAmount: json['codAmount'].toDouble(),
      isBuyAndDeliver: json['isBuyAndDeliver'],
    );
  }
}
