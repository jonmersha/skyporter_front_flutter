import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../utils/api_constants.dart';

class ProductShowroom extends StatefulWidget {
  const ProductShowroom({super.key});

  @override
  State<ProductShowroom> createState() => _ProductShowroomState();
}

class _ProductShowroomState extends State<ProductShowroom> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _rewardController = TextEditingController();
  final _arrivalDateController = TextEditingController();

  final List<XFile> _selectedImages = [];
  String _selectedCategory = "ELECTRONICS";
  bool _isLoading = false;

  final Color primaryDark = const Color(0xFF1A1A1A);
  final Color accentGold = const Color(0xFFECAE0B);
  final Color brandGreen = const Color(0xFF089348);

  // --- IMAGE PICKING LOGIC ---

  Future<void> _pickImage(ImageSource source) async {
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
      _showSnackBar("Error picking image: $e", Colors.redAccent);
    }
  }

  void _showPickerMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("Upload Product Images", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: accentGold),
              title: const Text('Choose from Gallery'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: accentGold),
              title: const Text('Take a Photo'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- API SUBMISSION ---

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      _showSnackBar("Please add at least one image", Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);
    String? token = await storage.read(key: 'access');

    try {
      // Use the specific endpoint for products. Note the trailing slash.
      var uri = Uri.parse("${ApiConstants.baseUrl}/api/traveler-products/");
      var request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers.addAll({
        'Authorization': 'JWT $token',
        'Accept': 'application/json',
      });

      // Text Fields
      request.fields['name'] = _nameController.text.trim();
      request.fields['description'] = _descController.text.trim();
      request.fields['category'] = _selectedCategory;
      request.fields['price'] = _priceController.text;
      request.fields['expected_reward'] = _rewardController.text;
      request.fields['arrival_date'] = _arrivalDateController.text;
      request.fields['expiration_time'] = "${_arrivalDateController.text}T23:59:59Z";

      // Attach Multiple Images
      for (var file in _selectedImages) {
        request.files.add(await http.MultipartFile.fromPath(
          'uploaded_images', // THIS KEY MUST MATCH DJANGO SERIALIZER
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }



      var streamResponse = await request.send();
      var res = await http.Response.fromStream(streamResponse);

      if (res.statusCode == 201) {
        if (mounted) {
          _showSnackBar("Product listed successfully!", brandGreen);
          Navigator.pop(context, true);
        }
      } else {
        debugPrint("Error Body: ${res.body}");
        _showSnackBar("Failed: ${res.statusCode}. Check server logs.", Colors.redAccent);
      }
    } catch (e) {
      debugPrint("Exception: $e");
      _showSnackBar("Network error occurred", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("List Product", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("OFFER ITEM FOR SALE", style: TextStyle(color: accentGold, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 12)),
              const SizedBox(height: 20),
              _buildImageSection(),
              const SizedBox(height: 25),
              _buildInput("Product Name", _nameController, hint: "e.g., iPhone 15 Pro Max"),
              _buildInput("Description", _descController, maxLines: 3, hint: "Condition, specs, etc."),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildInput("Price (\$)", _priceController, isNum: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput("Profit (\$)", _rewardController, isNum: true)),
                ],
              ),
              _buildDateInput(),
              const SizedBox(height: 40),
              _buildSubmitButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Product Images", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: _showPickerMenu,
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
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
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, {bool isNum = false, int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label, hintText: hint,
          filled: true, fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentGold, width: 2)),
        ),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField(
        value: _selectedCategory,
        items: ["ELECTRONICS", "FOOD_SUPPLEMENTS", "MEDICINES", "COSMETICS", "OTHERS"]
            .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (val) => setState(() => _selectedCategory = val as String),
        decoration: InputDecoration(
          labelText: "Category", filled: true, fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
      ),
    );
  }

  Widget _buildDateInput() {
    return TextFormField(
      controller: _arrivalDateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Arrival Date", prefixIcon: const Icon(Icons.calendar_today),
        filled: true, fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
            context: context, initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(), lastDate: DateTime(2027));
        if (picked != null) {
          setState(() => _arrivalDateController.text = DateFormat('yyyy-MM-dd').format(picked));
        }
      },
      validator: (v) => v!.isEmpty ? "Select date" : null,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("LIST PRODUCT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}