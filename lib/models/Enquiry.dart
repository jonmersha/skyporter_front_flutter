class Enquiry {
  final int id;
  final int senderId;
  final String senderName;
  final int receiverId;
  final String receiverName;
  final int? tripId;
  final int? productId;
  final int? requestId;
  final String message;
  final bool isAccepted;
  final String enquiryType; // e.g., "TRIP", "PRODUCT", or "REQUEST"
  final DateTime createdAt;

  Enquiry({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    this.tripId,
    this.productId,
    this.requestId,
    required this.message,
    required this.isAccepted,
    required this.enquiryType,
    required this.createdAt,
  });

  factory Enquiry.fromJson(Map<String, dynamic> json) {
    return Enquiry(
      id: json['id'] ?? 0,
      senderId: json['sender'] ?? 0,
      senderName: json['sender_name'] ?? "User",
      receiverId: json['receiver'] ?? 0,
      receiverName: json['receiver_name'] ?? "User",
      tripId: json['trip'],
      productId: json['product'],
      requestId: json['request'],
      message: json['message'] ?? "",
      isAccepted: json['is_accepted'] ?? false,
      enquiryType: json['enquiry_type'] ?? "GENERAL",
      createdAt: DateTime.parse(json['created_at'] ?? "2026-01-01T00:00:00Z"),
    );
  }
}
