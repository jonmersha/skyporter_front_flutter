import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Required for MediaType
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../utils/api_constants.dart';

class PostProductPage extends StatefulWidget {
  const PostProductPage({super.key});

  @override
  State<PostProductPage> createState() => _PostProductPageState();
}

class _PostProductPageState extends State<PostProductPage> {
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

  // Skyport Brand Palette
  final Color primaryDark = const Color(0xFF1A1A1A);
  final Color accentGold = const Color(0xFFECAE0B);
  final Color brandGreen = const Color(0xFF089348);

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        setState(() => _selectedImages.addAll(images));
      }
    } else {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (photo != null) {
        setState(() => _selectedImages.add(photo));
      }
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
              child: Text("Upload Product Image", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add at least one image")));
      return;
    }

    setState(() => _isLoading = true);
    String? token = await storage.read(key: 'access');

    try {
      var request = http.MultipartRequest('POST', Uri.parse("${ApiConstants.baseUrl}/api/traveler-products/"));
      request.headers.addAll({'Authorization': 'JWT $token', 'Accept': 'application/json'});

      request.fields['name'] = _nameController.text.trim();
      request.fields['description'] = _descController.text.trim();
      request.fields['category'] = _selectedCategory;
      request.fields['price'] = _priceController.text;
      request.fields['expected_reward'] = _rewardController.text;
      request.fields['arrival_date'] = _arrivalDateController.text;
      request.fields['expiration_time'] = "${_arrivalDateController.text}T23:59:59Z";

      for (var file in _selectedImages) {
        request.files.add(await http.MultipartFile.fromPath(
          'uploaded_images',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var streamResponse = await request.send();
      var res = await http.Response.fromStream(streamResponse);

      if (res.statusCode == 201) {
        if (mounted) Navigator.pop(context, true);
      } else {
        debugPrint("Error: ${res.body}");
      }
    } catch (e) {
      debugPrint("Exception: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
              _buildInput("Description", _descController, maxLines: 3, hint: "Describe condition, specs, or details..."),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildInput("Price (\$)", _priceController, isNum: true, hint: "1200")),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput("Profit (\$)", _rewardController, isNum: true, hint: "150")),
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
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: Icon(Icons.add_a_photo_rounded, color: Colors.grey[400], size: 30),
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
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentGold, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent)),
        ),
        validator: (v) => v!.isEmpty ? "Required field" : null,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField(
        value: _selectedCategory,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        items: ["ELECTRONICS", "FOOD_SUPPLEMENTS", "MEDICINES", "COSMETICS", "OTHERS"]
            .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: (val) => setState(() => _selectedCategory = val as String),
        decoration: InputDecoration(
          labelText: "Category",
          filled: true,
          fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentGold, width: 2)),
        ),
      ),
    );
  }

  Widget _buildDateInput() {
    return TextFormField(
      controller: _arrivalDateController,
      readOnly: true,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: "Expected Arrival Date",
        prefixIcon: Icon(Icons.calendar_month_rounded, color: primaryDark),
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentGold, width: 2)),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
            context: context, initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(), lastDate: DateTime(2027));
        if (picked != null) {
          setState(() => _arrivalDateController.text = DateFormat('yyyy-MM-dd').format(picked));
        }
      },
      validator: (v) => v!.isEmpty ? "Select arrival date" : null,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("LIST PRODUCT FOR SALE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
      ),
    );
  }
}