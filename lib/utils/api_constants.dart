class ApiConstants {
  // Base URL - Replace with your server IP or domain
  // Use http://10.0.2.2:8000 for Android Emulator to reach localhost
  static const String baseUrl = "http://10.11.241.51:8000";

  // --- AUTH ENDPOINTS (Djoser + SimpleJWT) ---
  static const String login = "$baseUrl/auth/jwt/create/";
  static const String register = "$baseUrl/auth/users/";
  static const String refreshToken = "$baseUrl/auth/jwt/refresh/";
  static const String verifyToken = "$baseUrl/auth/jwt/verify/";
  static const String userMe = "$baseUrl/auth/users/me/";
  static const String resetPassword = "$baseUrl/auth/users/reset_password/";
  static const String setPassword = "$baseUrl/auth/users/set_password/";
  static const String activateUser = "$baseUrl/auth/users/activation/";

  // --- MARKETPLACE ENDPOINTS ---
  static const String trips = "$baseUrl/api/trips/";
  static const String requests = "$baseUrl/api/requests/";
  static const String deals = "$baseUrl/api/deals/";
  static const String profiles = "$baseUrl/api/profile/";

  // --- HELPER FOR HEADERS ---
  static Map<String, String> authHeader(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization':
          'JWT $token', // Djoser uses 'JWT', not 'Bearer' by default
    };
  }

  static const Map<String, String> publicHeader = {
    'Content-Type': 'application/json',
  };
}
