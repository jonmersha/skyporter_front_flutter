import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
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

  // --- Logic: Pick Image ---
  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        setState(() => _selectedImages.addAll(images));
      }
    } else {
      final XFile? photo =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (photo != null) {
        setState(() => _selectedImages.add(photo));
      }
    }
  }

  void _showPickerMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Logic: Submit ---
  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate() || _selectedImages.isEmpty) return;

    setState(() => _isLoading = true);
    String? token = await storage.read(key: 'access');

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse("${ApiConstants.baseUrl}/api/traveler-products/"));
      request.headers.addAll(
          {'Authorization': 'JWT $token', 'Accept': 'application/json'});

      // Fields
      request.fields['name'] = _nameController.text;
      request.fields['description'] = _descController.text;
      request.fields['category'] = _selectedCategory;
      request.fields['price'] = _priceController.text;
      request.fields['expected_reward'] = _rewardController.text;
      request.fields['arrival_date'] = _arrivalDateController.text;
      request.fields['expiration_time'] =
          "${_arrivalDateController.text}T23:59:59Z";

      // Images
      for (var file in _selectedImages) {
        request.files.add(await http.MultipartFile.fromPath(
          'uploaded_images',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var res = await http.Response.fromStream(await request.send());

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
      appBar: AppBar(title: const Text("List a Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePreview(),
              const SizedBox(height: 20),
              _buildInput("Product Name", _nameController),
              _buildInput("Description", _descController, maxLines: 3),
              _buildCategoryDropdown(),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                      child:
                          _buildInput("Price", _priceController, isNum: true)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildInput("Profit", _rewardController,
                          isNum: true)),
                ],
              ),
              _buildDateInput(),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(_selectedImages[index].path),
                      width: 100, height: 100, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        TextButton.icon(
          onPressed: _showPickerMenu,
          icon: const Icon(Icons.add_a_photo),
          label: const Text("Add Images (Camera/Gallery)"),
        ),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl,
      {bool isNum = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
            labelText: label,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField(
      initialValue: _selectedCategory,
      items: [
        "ELECTRONICS",
        "FOOD_SUPPLEMENTS",
        "MEDICINES",
        "COSMETICS",
        "OTHERS"
      ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val as String),
      decoration: const InputDecoration(
          labelText: "Category", border: OutlineInputBorder()),
    );
  }

  Widget _buildDateInput() {
    return TextFormField(
      controller: _arrivalDateController,
      readOnly: true,
      decoration: const InputDecoration(
          labelText: "Arrival Date", prefixIcon: Icon(Icons.calendar_today)),
      onTap: () async {
        DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2027));
        if (picked != null) {
          setState(() => _arrivalDateController.text =
              DateFormat('yyyy-MM-dd').format(picked));
        }
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitProduct,
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          minimumSize: const Size(double.infinity, 55)),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("LIST PRODUCT", style: TextStyle(color: Colors.white)),
    );
  }
}
