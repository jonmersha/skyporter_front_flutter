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

  final _titleController = TextEditingController();
  final _fromCityController = TextEditingController();
  final _toCityController = TextEditingController();
  final _dateController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descController = TextEditingController();

  bool isPurchase = false;
  // This must match your Django Category.choices exactly
  String _selectedCategory = "ELECTRONICS";
  bool _isLoading = false;

  // Map for UI Display vs Backend Keys
  final Map<String, String> categoryOptions = {
    "ELECTRONICS": "Electronics",
    "FOOD_SUPPLEMENTS": "Food & Supplements",
    "MEDICINES": "Medicines",
    "COSMETICS": "Cosmetics",
    "OTHERS": "Others",
  };

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    String? token = await storage.read(key: 'access');

    try {
      final url = Uri.parse("${ApiConstants.baseUrl}/api/customer-requests/");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonEncode({
          "title": _titleController.text.trim(),
          "request_type": isPurchase ? "BUY_TRANSPORT" : "TRANSPORT_ONLY",
          "category": _selectedCategory,
          "from_city": _fromCityController.text.trim(),
          "to_city": _toCityController.text.trim(),
          "preferred_delivery_date": _dateController.text,
          "budget": double.parse(_budgetController.text), // Send as double, not String
          "description": _descController.text.trim(),
          "is_open": true
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Success! Posted to Marketplace")),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Detailed error logging
        final errorBody = jsonDecode(response.body);
        print("Backend Error: $errorBody");
        throw Exception(errorBody.toString());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString().replaceAll('Exception:', '')}")),
      );
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
              _buildInput("What do you need?", Icons.shopping_bag, _titleController),
              _buildCategoryDropdown(),
              const SizedBox(height: 15),
              _buildInput("Pickup City", Icons.location_on, _fromCityController),
              _buildInput("Destination City", Icons.home, _toCityController),
              _buildDateInput(),

              Card(
                color: Colors.blue.withOpacity(0.05),
                child: SwitchListTile(
                  title: const Text("Buy & Transport"),
                  subtitle: const Text("Traveler buys the item for you first"),
                  value: isPurchase,
                  onChanged: (v) => setState(() => isPurchase = v),
                ),
              ),

              _buildInput("Budget / Reward (\$)", Icons.attach_money, _budgetController, isNum: true),
              _buildInput("Details (Link, Size, etc.)", Icons.notes, _descController, maxLines: 3),

              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Post Request"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(labelText: "Category", prefixIcon: Icon(Icons.category)),
      items: categoryOptions.entries.map((entry) {
        return DropdownMenuItem(value: entry.key, child: Text(entry.value));
      }).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val!),
    );
  }

  Widget _buildInput(String label, IconData icon, TextEditingController ctrl, {bool isNum = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildDateInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        decoration: const InputDecoration(labelText: "Delivery Date", prefixIcon: Icon(Icons.calendar_month)),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 7)),
            firstDate: DateTime.now(),
            lastDate: DateTime(2027),
          );
          if (picked != null) {
            setState(() => _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
          }
        },
      ),
    );
  }
}