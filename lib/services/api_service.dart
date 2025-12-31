import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shipment_model.dart';
import '../utils/constants.dart';

class ApiService {
  // Singleton pattern to ensure only one instance of the service exists
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Fetches all shipments assigned to the current user (as either Carrier or Sender)
  Future<List<Shipment>> fetchMyShipments() async {
    // In a real scenario, you would use:
    // final response = await http.get(Uri.parse('${AppConstants.internalApiBaseUrl}/shipments'));

    // Simulating API Latency
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Mocking the JSON response from your tracking system
      final List<Map<String, dynamic>> mockData = [
        {
          "id": "SHP-9921",
          "flightNo": "EK201",
          "origin": "DXB",
          "destination": "JFK",
          "status": "In-Transit",
          "itemDescription": "Sony Alpha A7 IV Camera",
          "weight": 0.8,
          "codAmount": 2500.0,
          "isBuyAndDeliver": true
        },
        {
          "id": "SHP-4432",
          "flightNo": "LH400",
          "origin": "FRA",
          "destination": "JFK",
          "status": "Landed",
          "itemDescription": "Legal Documents & Keys",
          "weight": 0.2,
          "codAmount": 50.0,
          "isBuyAndDeliver": false
        }
      ];

      return mockData.map((json) => Shipment.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Failed to parse shipment data: $e");
    }
  }

  /// Updates the flight status by calling your Flight Tracking API
  Future<Map<String, dynamic>> getLiveFlightStatus(String flightNo) async {
    // Example using Aviationstack or similar API
    // final response = await http.get(Uri.parse('${AppConstants.flightApiBaseUrl}/flights?flight_iata=$flightNo&access_key=YOUR_KEY'));

    // Mocking Real-time API Update
    return {
      "altitude": 35000,
      "estimated_arrival": "2025-12-31T20:30:00Z",
      "live_location": {"lat": 40.7128, "lng": -74.0060},
      "delay_minutes": 15
    };
  }

  /// Verifies the delivery via OTP (Final Step in User Story)
  Future<bool> verifyDelivery(String shipmentId, String otpCode) async {
    // Calling your backend to verify the offline payment was confirmed by OTP
    // final response = await http.post(
    //   Uri.parse('${AppConstants.internalApiBaseUrl}/verify'),
    //   body: {'id': shipmentId, 'otp': otpCode},
    // );

    // For now, simulate success
    return otpCode == "1234";
  }
}