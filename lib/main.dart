import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyporters/pages/navigation/main_navigation_page.dart';

// Internal Imports
import 'utils/constants.dart';
import 'pages/toberemoved/dashboard_page.dart';

void main() {
  // Ensure Flutter bindings are initialized before any API calls
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SkyPortersApp());
}

class SkyPortersApp extends StatelessWidget {
  const SkyPortersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // --- GLOBAL THEME CONFIGURATION ---
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          primary: AppConstants.primaryColor,
          secondary: AppConstants.accentColor,
          surface: Colors.white,
        ),

        // Typography
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),

        // Fixed: Parameter type 'CardThemeData?' fix
        cardTheme: CardThemeData(
          elevation: 2,
          color: Colors.white,
          surfaceTintColor: Colors.white, // Disables Material 3 purple tint
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),

        // AppBar Styling
        appBarTheme: AppBarTheme(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        // Button Styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      // --- ROUTING ---
      home:  const MainNavigationPage(),
    );
  }
}