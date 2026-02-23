import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../utils/api_constants.dart';

class PostProductRequest extends StatefulWidget {
  const PostProductRequest({super.key});

  @override
  State<PostProductRequest> createState() => _PostProductRequestState();
}

class _PostProductRequestState extends State<PostProductRequest> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

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

  List<XFile> _selectedImages = [];
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

  // --- UPDATED IMAGE PICKING LOGIC ---

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(
              title: Text("Select Image Source",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: accentGold),
              title: const Text("Gallery (Multiple)"),
              onTap: () {
                Navigator.pop(context);
                _handleImageSelection(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: accentGold),
              title: const Text("Camera (Single Photo)"),
              onTap: () {
                Navigator.pop(context);
                _handleImageSelection(ImageSource.camera);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage(imageQuality: 50);
        if (images.isNotEmpty) {
          setState(() => _selectedImages.addAll(images));
        }
      } else {
        final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
        if (photo != null) {
          setState(() => _selectedImages.add(photo));
        }
      }
    } catch (e) {
      _showSnackBar("Could not access images", Colors.redAccent);
    }
  }

  // --- API SUBMISSION ---

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      _showSnackBar("Please add at least one image of the item", Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);
    String? token = await storage.read(key: 'access');

    try {
      final url = Uri.parse("${ApiConstants.baseUrl}/api/customer-requests/");
      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': 'JWT $token',
        'Accept': 'application/json',
      });

      request.fields['title'] = _titleController.text.trim();
      request.fields['request_type'] = isPurchase ? "BUY_TRANSPORT" : "TRANSPORT_ONLY";
      request.fields['category'] = _selectedCategory;
      request.fields['from_city'] = _fromCityController.text.trim();
      request.fields['to_city'] = _toCityController.text.trim();
      request.fields['preferred_delivery_date'] = _dateController.text;
      request.fields['budget'] = _budgetController.text;
      request.fields['description'] = _descController.text.trim();
      request.fields['is_open'] = "true";

      for (var file in _selectedImages) {
        request.files.add(await http.MultipartFile.fromPath(
          'uploaded_images',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }



      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        if (mounted) {
          _showSnackBar("Request successfully posted!", brandGreen);
          Navigator.pop(context, true);
        }
      } else {
        _showSnackBar("Failed to post request.", Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar("Network error.", Colors.orange);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  // --- UI COMPONENTS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: true,
        title: const Text("REQUEST AN ITEM",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("ITEM PHOTOS"),
              _buildImagePickerArea(),
              const SizedBox(height: 25),

              _buildSectionHeader("ITEM DETAILS"),
              _buildInput("Title", Icons.shopping_bag_outlined, _titleController, hint: "e.g. Laptop Charger"),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),

              _buildSectionHeader("LOGISTICS"),
              _buildInput("From City", Icons.location_on_outlined, _fromCityController),
              _buildInput("To City", Icons.home_outlined, _toCityController),
              _buildDateInput(),
              _buildTypeSelector(),
              const SizedBox(height: 25),

              _buildSectionHeader("BUDGET & DETAILS"),
              _buildInput("Budget / Reward (\$)", Icons.attach_money_rounded, _budgetController, isNum: true),
              _buildInput("Description", Icons.notes_rounded, _descController, maxLines: 3),

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

  Widget _buildImagePickerArea() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: _showImageSourceOptions, // Updated to show options
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(Icons.add_a_photo_rounded, color: accentGold, size: 30),
            ),
          ),
          ..._selectedImages.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(File(entry.value.path), width: 100, height: 100, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 5, right: 5,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImages.removeAt(entry.key)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: primaryDark.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        title: const Text("Buy & Transport", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        subtitle: const Text("Traveler buys item for you"),
        activeColor: accentGold,
        value: isPurchase,
        onChanged: (v) => setState(() => isPurchase = v),
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
        decoration: InputDecoration(
          labelText: label, hintText: hint,
          prefixIcon: Icon(icon, color: primaryDark, size: 22),
          filled: true, fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentGold, width: 2)),
        ),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: "Category", prefixIcon: Icon(Icons.category_outlined, color: primaryDark),
        filled: true, fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
      items: categoryOptions.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value))).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val!),
    );
  }

  Widget _buildDateInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Delivery Date", prefixIcon: Icon(Icons.calendar_month_outlined, color: primaryDark),
          filled: true, fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context, initialDate: DateTime.now().add(const Duration(days: 7)),
            firstDate: DateTime.now(), lastDate: DateTime(2027),
          );
          if (picked != null) setState(() => _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
        },
        validator: (v) => v!.isEmpty ? "Select a date" : null,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("POST REQUEST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
    );
  }
}