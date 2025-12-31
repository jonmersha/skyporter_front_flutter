class PassengerPost {
  final String id, travelerName, from, to, date, contact;
  final double pricePerKg, laptopFee, smartphoneFee, availableKg;

  PassengerPost({
    required this.id, required this.travelerName, required this.from,
    required this.to, required this.date, required this.contact,
    required this.pricePerKg, required this.laptopFee,
    required this.smartphoneFee, required this.availableKg,
  });
}