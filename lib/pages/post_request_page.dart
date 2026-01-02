import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../utils/api_constants.dart';

class PostRequestPage extends StatefulWidget {
  const PostRequestPage({super.key});

  @override
  State<PostRequestPage> createState() => _PostRequestPageState();
}

class _PostRequestPageState extends State<PostRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  // Controllers
  final _titleController = TextEditingController();
  final _fromCityController = TextEditingController();
  final _toCityController = TextEditingController();
  final _dateController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descController = TextEditingController();

  bool isPurchase = false; // Toggle for request_type
  String _selectedCategory = "ELECTRONICS";
  bool _isLoading = false;

  // --- Logic: Submit to Django ---
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? token = await storage.read(key: 'access');

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/customer-requests/"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonEncode({
          "title": _titleController.text,
          // If switch is ON, they buy and transport. If OFF, just transport.
          "request_type": isPurchase ? "BUY_TRANSPORT" : "TRANSPORT_ONLY",
          "category": _selectedCategory,
          "from_city": _fromCityController.text,
          "to_city": _toCityController.text,
          "preferred_delivery_date": _dateController.text,
          "budget": double.tryParse(_budgetController.text) ?? 0.0,
          "description": _descController.text,
          "is_open": true
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Request posted to Marketplace!"),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        debugPrint("Error: ${response.body}");
        throw Exception("Failed to post request");
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request an Item")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput("Item Name", Icons.shopping_bag, _titleController),
              _buildCategoryDropdown(),
              const SizedBox(height: 15),
              _buildInput(
                  "Pickup From (City)", Icons.location_on, _fromCityController),
              _buildInput("Deliver To (City)", Icons.home, _toCityController),
              _buildDateInput(),
              SwitchListTile(
                title: const Text("I need the traveler to buy this for me"),
                subtitle: Text(isPurchase
                    ? "Request Type: Buy & Transport"
                    : "Request Type: Transport Only"),
                value: isPurchase,
                activeColor: Colors.green[700],
                onChanged: (v) => setState(() => isPurchase = v),
              ),
              _buildInput(
                  "Budget / Reward (\$)", Icons.attach_money, _budgetController,
                  isNum: true),
              _buildInput(
                  "Description / Details", Icons.description, _descController,
                  maxLines: 3),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Post Request to Marketplace",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildInput(String label, IconData icon, TextEditingController ctrl,
      {bool isNum = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField(
      value: _selectedCategory,
      items: ["ELECTRONICS", "COSMETICS", "MEDICINES", "FOOD", "OTHERS"]
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (val) => setState(() => _selectedCategory = val as String),
      decoration: InputDecoration(
        labelText: "Category",
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDateInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Preferred Delivery Date",
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2027),
          );
          if (picked != null) {
            setState(() =>
                _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
          }
        },
        validator: (v) =>
            v == null || v.isEmpty ? "Please select a date" : null,
      ),
    );
  }
}
