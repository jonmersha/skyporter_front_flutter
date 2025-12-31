import 'package:flutter/material.dart';

class AppConstants {
  // App Strings
  static const String appName = "SkyPorters";
  static const String appVersion = "1.0.0";

  // API Endpoints (Placeholders for your existing tracking API)
  static const String flightApiBaseUrl = "https://api.aviationstack.com/v1/";
  static const String internalApiBaseUrl = "https://your-backend-api.com/v2/";

  // Colors
  static const Color primaryColor = Color(0xFF1A237E); // Deep Indigo
  static const Color accentColor = Color(0xFF00C853);  // Success Green
  static const Color errorColor = Color(0xFFD32F2F);   // Alert Red

  // Padding & Styling
  static const double defaultPadding = 16.0;
  static const double borderRadius = 12.0;
}