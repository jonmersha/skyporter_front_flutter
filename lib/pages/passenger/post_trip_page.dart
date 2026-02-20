import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../utils/api_constants.dart';

class PostTripPage extends StatefulWidget {
  const PostTripPage({super.key});

  @override
  State<PostTripPage> createState() => _PostTripPageState();
}

class _PostTripPageState extends State<PostTripPage> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  final Color primaryDark = const Color(0xFF1A1A1A);
  final Color accentGold = const Color(0xFFECAE0B);
  final Color brandGreen = const Color(0xFF089348);

  final _departureCityCtrl = TextEditingController();
  final _destinationCityCtrl = TextEditingController();
  final _departureDateCtrl = TextEditingController(); // NEW
  final _arrivalDateCtrl = TextEditingController();

  final _laptopFeeCtrl = TextEditingController(text: "50.00");
  final _mobileFeeCtrl = TextEditingController(text: "30.00");
  final _cosmeticFeeCtrl = TextEditingController(text: "10.00");
  final _otherFeeCtrl = TextEditingController(text: "15.00");

  bool _isLoading = false;

  Future<void> _submitTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    String? token = await storage.read(key: 'access');

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/trips/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonEncode({
          "departure_city": _departureCityCtrl.text.trim(),
          "destination_city": _destinationCityCtrl.text.trim(),
          "departure_date": _departureDateCtrl.text, // NEW
          "arrival_date": _arrivalDateCtrl.text,
          "laptop_fee": double.parse(_laptopFeeCtrl.text),
          "mobile_fee": double.parse(_mobileFeeCtrl.text),
          "cosmetic_fee": double.parse(_cosmeticFeeCtrl.text),
          "other_fee": double.parse(_otherFeeCtrl.text),
          "is_active": true
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          _showSnackBar("Trip Posted!", brandGreen);
          Navigator.pop(context, true);
        }
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar("Error: ${error.toString()}", Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar("Network Error", Colors.orange);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: primaryDark,
        title: const Text("REGISTER TRIP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("ROUTE & TIMING"),
              _buildInput("Departure City", Icons.flight_takeoff, _departureCityCtrl),
              _buildInput("Destination City", Icons.flight_land, _destinationCityCtrl),

              Row(
                children: [
                  Expanded(child: _buildDatePicker("Departure", _departureDateCtrl)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildDatePicker("Arrival", _arrivalDateCtrl)),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 15),

              _buildSectionHeader("FEES (\$USD)"),
              Row(
                children: [
                  Expanded(child: _buildInput("Laptop", Icons.laptop, _laptopFeeCtrl, isNum: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput("Mobile", Icons.smartphone, _mobileFeeCtrl, isNum: true)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildInput("Cosmetic", Icons.face, _cosmeticFeeCtrl, isNum: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput("Other", Icons.inventory_2, _otherFeeCtrl, isNum: true)),
                ],
              ),

              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Text(title, style: TextStyle(color: accentGold, fontWeight: FontWeight.bold, fontSize: 12)),
  );

  Widget _buildInput(String label, IconData icon, TextEditingController ctrl, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryDark, size: 20),
          filled: true,
          fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentGold, width: 2)),
        ),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildDatePicker(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.calendar_today, color: primaryDark, size: 18),
          filled: true,
          fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentGold, width: 2)),
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: primaryDark)),
              child: child!,
            ),
          );
          if (picked != null) {
            setState(() => ctrl.text = DateFormat('yyyy-MM-dd').format(picked));
          }
        },
        validator: (v) => v!.isEmpty ? "Select" : null,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitTrip,
        style: ElevatedButton.styleFrom(backgroundColor: primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("POST TRIP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}