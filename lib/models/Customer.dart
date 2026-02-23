// class CustomerRequest {
//   final int id;
//   final int customer; // The User ID for the enquiry receiver
//   final String customerName;
//   final String title;
//   final String description; // Added for the detail card
//   final String requestType;
//   final String category;
//   final String fromCity;
//   final String toCity;
//   final String preferredDeliveryDate; // Added for timeline logic
//   final double budget;
//   final bool isOpen;
//
//   CustomerRequest({
//     required this.id,
//     required this.customer,
//     required this.customerName,
//     required this.title,
//     required this.description,
//     required this.requestType,
//     required this.category,
//     required this.fromCity,
//     required this.toCity,
//     required this.preferredDeliveryDate,
//     required this.budget,
//     required this.isOpen,
//   });
//
//   // --- UI Helper: Get Relative Timeline ---
//   String get timelineStatus {
//     try {
//       DateTime delivery = DateTime.parse(preferredDeliveryDate);
//       DateTime now = DateTime.now();
//       // Calculate difference in days (ignoring time)
//       int diff = DateTime(delivery.year, delivery.month, delivery.day)
//           .difference(DateTime(now.year, now.month, now.day))
//           .inDays;
//
//       if (diff == 0) return "Today";
//       if (diff == 1) return "Tomorrow";
//       if (diff < 0) return "Expired";
//       return "$diff days left";
//     } catch (e) {
//       return "Flexible";
//     }
//   }
//
//   factory CustomerRequest.fromJson(Map<String, dynamic> json) =>
//       CustomerRequest(
//         id: json['id'] ?? 0,
//         customer: json['customer'] ?? 0, // Maps to 'customer' in your API
//         customerName: json['customer_name'] ?? "Anonymous",
//         title: json['title'] ?? "",
//         description: json['description'] ?? "No description provided.",
//         requestType: json['request_type'] ?? "BUY_TRANSPORT",
//         category: json['category'] ?? "OTHER",
//         fromCity: json['from_city'] ?? "",
//         toCity: json['to_city'] ?? "",
//         preferredDeliveryDate: json['preferred_delivery_date'] ?? "",
//         budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
//         isOpen: json['is_open'] ?? true,
//       );
//
//   Map<String, dynamic> toJson() => {
//         "title": title,
//         "description": description,
//         "request_type": requestType,
//         "category": category,
//         "from_city": fromCity,
//         "to_city": toCity,
//         "preferred_delivery_date": preferredDeliveryDate,
//         "budget": budget,
//         "is_open": isOpen,
//       };
// }

class CustomerRequest {
  final int id;
  final String title;
  final String requestType;
  final String category;
  final String fromCity;
  final String toCity;
  final String preferredDeliveryDate;
  final double budget;
  final String description;
  final bool isOpen;
  final List<String> images; // List of parsed image URLs

  CustomerRequest({
    required this.id,
    required this.title,
    required this.requestType,
    required this.category,
    required this.fromCity,
    required this.toCity,
    required this.preferredDeliveryDate,
    required this.budget,
    required this.description,
    required this.isOpen,
    required this.images,
  });

  factory CustomerRequest.fromJson(Map<String, dynamic> json) {
    return CustomerRequest(
      id: json['id'],
      title: json['title'],
      requestType: json['request_type'],
      category: json['category'],
      fromCity: json['from_city'],
      toCity: json['to_city'],
      preferredDeliveryDate: json['preferred_delivery_date'],
      budget: double.parse(json['budget'].toString()),
      description: json['description'],
      isOpen: json['is_open'],
      // Map the nested images list to a list of Strings (URLs)
      images: (json['images'] as List?)
          ?.map((item) => item['image'] as String)
          .toList() ?? [],
    );
  }
}