import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../utils/api_constants.dart';

class PostProductRequest extends StatefulWidget {
  const PostProductRequest({super.key});

  @override
  State<PostProductRequest> createState() => _PostProductRequestState();
}

class _PostProductRequestState extends State<PostProductRequest> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  // Skyport Brand Palette
  final Color primaryDark = const Color(0xFF1A1A1A);
  final Color accentGold = const Color(0xFFECAE0B);
  final Color brandGreen = const Color(0xFF089348);

  final _titleController = TextEditingController();
  final _fromCityController = TextEditingController();
  final _toCityController = TextEditingController();
  final _dateController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descController = TextEditingController();

  bool isPurchase = false;
  String _selectedCategory = "ELECTRONICS";
  bool _isLoading = false;

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

    // Check for token - ensuring the user is authenticated
    String? token = await storage.read(key: 'access');
    if (token == null) {
      _showSnackBar("Session expired. Please log in again.", Colors.redAccent);
      setState(() => _isLoading = false);
      return;
    }

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
          "budget": double.parse(_budgetController.text),
          "description": _descController.text.trim(),
          "is_open": true
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          _showSnackBar("Success! Posted to Marketplace", brandGreen);
          Navigator.pop(context, true);
        }
      } else {
        final errorBody = jsonDecode(response.body);
        debugPrint("Backend Error: $errorBody");
        _showSnackBar("Failed: ${errorBody.toString()}", Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar("Connection error. Try again.", Colors.orange);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "REQUEST AN ITEM",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("ITEM DETAILS"),
              _buildInput("What do you need?", Icons.shopping_bag_outlined, _titleController, hint: "e.g. iPhone Case"),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),

              _buildSectionHeader("LOGISTICS"),
              _buildInput("Pickup City", Icons.location_on_outlined, _fromCityController, hint: "City of origin"),
              _buildInput("Destination City", Icons.home_outlined, _toCityController, hint: "Delivery city"),
              _buildDateInput(),
              const SizedBox(height: 10),

              _buildTypeSelector(),
              const SizedBox(height: 25),

              _buildSectionHeader("BUDGET & REWARD"),
              _buildInput("Budget / Reward (\$)", Icons.attach_money_rounded, _budgetController, isNum: true, hint: "0.00"),
              _buildInput("Details (Link, Size, etc.)", Icons.notes_rounded, _descController, maxLines: 3),

              const SizedBox(height: 30),
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(color: accentGold, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 12),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: primaryDark.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        title: const Text("Buy & Transport", style: TextStyle(fontWeight: FontWeight.w800)),
        subtitle: const Text("Traveler buys the item for you first"),
        activeColor: accentGold,
        value: isPurchase,
        onChanged: (v) => setState(() => isPurchase = v),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: "Category",
          prefixIcon: Icon(Icons.category_outlined, color: primaryDark),
          filled: true,
          fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentGold, width: 2)),
        ),
        items: categoryOptions.entries.map((entry) {
          return DropdownMenuItem(value: entry.key, child: Text(entry.value));
        }).toList(),
        onChanged: (val) => setState(() => _selectedCategory = val!),
      ),
    );
  }

  Widget _buildInput(String label, IconData icon, TextEditingController ctrl, {bool isNum = false, int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: primaryDark, size: 22),
          filled: true,
          fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentGold, width: 2)),
        ),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildDateInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: "Delivery Date",
          prefixIcon: Icon(Icons.calendar_month_outlined, color: primaryDark),
          filled: true,
          fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentGold, width: 2)),
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 7)),
            firstDate: DateTime.now(),
            lastDate: DateTime(2027),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(primary: primaryDark, onPrimary: Colors.white, onSurface: primaryDark),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() => _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
          }
        },
        validator: (v) => v!.isEmpty ? "Select a date" : null,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("POST REQUEST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
      ),
    );
  }
}