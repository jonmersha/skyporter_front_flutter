import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../utils/api_constants.dart';

class PostTripPage extends StatefulWidget {
  const PostTripPage({super.key});

  @override
  State<PostTripPage> createState() => _PostTripPageState();
}

class _PostTripPageState extends State<PostTripPage> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  // Updated controllers to match the new API schema
  final _departureController = TextEditingController();
  final _destinationController = TextEditingController();
  final _arrivalDateController = TextEditingController();
  final _laptopFeeController = TextEditingController();
  final _mobileFeeController = TextEditingController();
  final _cosmeticFeeController = TextEditingController();
  final _otherFeeController = TextEditingController();

  bool _isLoading = false;

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _arrivalDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? token = await storage.read(key: 'access');

      // Matching the exact schema from your CURL command
      final Map<String, dynamic> tripData = {
        "departure_city": _departureController.text,
        "destination_city": _destinationController.text,
        "arrival_date": _arrivalDateController.text, // Format: YYYY-MM-DD
        "laptop_fee": double.tryParse(_laptopFeeController.text) ?? 0,
        "mobile_fee": double.tryParse(_mobileFeeController.text) ?? 0,
        "cosmetic_fee": double.tryParse(_cosmeticFeeController.text) ?? 0,
        "other_fee_base": double.tryParse(_otherFeeController.text) ?? 0,
        "is_active": true
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/trips/"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'JWT $token', // JWT Prefix as per your CURL
        },
        body: jsonEncode(tripData),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Trip published successfully!"),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData.toString());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Your Trip"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Route Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 15),
              _buildInput(
                  "Departure City", Icons.flight_takeoff, _departureController),
              _buildInput("Destination City", Icons.flight_land,
                  _destinationController),
              _buildDateInput(),
              const Divider(height: 40),
              const Text("Fee Structure (\$)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 15),
              _buildInput("Laptop Fee", Icons.laptop, _laptopFeeController,
                  isNumber: true),
              _buildInput(
                  "Mobile Fee", Icons.phone_android, _mobileFeeController,
                  isNumber: true),
              _buildInput("Cosmetics Fee", Icons.face, _cosmeticFeeController,
                  isNumber: true),
              _buildInput(
                  "Other Items (Base Fee)", Icons.category, _otherFeeController,
                  isNumber: true),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("PUBLISH TRIP",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- Reusable Components ---

  Widget _buildInput(
      String label, IconData icon, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildDateInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: _arrivalDateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Arrival Date",
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.indigo),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onTap: _selectDate,
        validator: (value) =>
            value == null || value.isEmpty ? "Select date" : null,
      ),
    );
  }
}
