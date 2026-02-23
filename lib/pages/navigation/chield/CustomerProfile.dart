import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:skyporters/utils/api_constants.dart';
import 'package:skyporters/pages/auth/login_page.dart';
import 'package:skyporters/pages/passenger/post_trip_page.dart';
import 'package:skyporters/pages/profile/new_product_showroom.dart';
import '../../profile/post_request_page.dart';
import '../../profile/my_listings_page.dart';

class CustomerDealList extends StatefulWidget {
  const CustomerDealList({super.key});

  @override
  State<CustomerDealList> createState() => _CustomerDealListState();
}

class _CustomerDealListState extends State<CustomerDealList> {
  final storage = const FlutterSecureStorage();
  late Future<Map<String, dynamic>> _userDataFuture;
  final ImagePicker _picker = ImagePicker();

  final Color primaryDark = const Color(0xFF1A1A1A);
  final Color accentGold = const Color(0xFFECAE0B);
  final Color brandGreen = const Color(0xFF089348);

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  // --- API SERVICES ---

  Future<Map<String, dynamic>> _fetchUserData() async {
    String? token = await storage.read(key: 'access');
    if (token == null) throw Exception("Session expired");

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.userMe),
        headers: {'Authorization': 'JWT $token', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 401) {
        _handleLogout();
        throw Exception("Unauthorized");
      }
      throw Exception("Server Error");
    } catch (e) {
      throw Exception("Failed to sync profile");
    }
  }

  // --- IMAGE UPLOAD LOGIC ---

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _handleImageUpload(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _handleImageUpload(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImageUpload(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
        source: source, imageQuality: 50, maxWidth: 800);
    if (image == null) return;

    _showLoading();
    String? token = await storage.read(key: 'access');

    try {
      var request =
          http.MultipartRequest('PATCH', Uri.parse(ApiConstants.userMe));
      request.headers['Authorization'] = 'JWT $token';

      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture', // Ensure this matches Django model/serializer
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        setState(() {
          _userDataFuture = _fetchUserData();
        });
        _showSnackBar("Profile photo updated!", brandGreen);
      } else {
        _showSnackBar("Upload failed", Colors.redAccent);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar("Connection error", Colors.redAccent);
    }
  }

  // --- TEXT UPDATE LOGIC ---

  Future<void> _updateProfileText(
      String fName, String lName, String phone) async {
    String? token = await storage.read(key: 'access');
    _showLoading();

    try {
      final response = await http.patch(
        Uri.parse(ApiConstants.userMe),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonEncode({
          "first_name": fName.trim(),
          "last_name": lName.trim(),
          "phone_number": phone.trim(),
        }),
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        setState(() {
          _userDataFuture = _fetchUserData();
        });
        _showSnackBar("Profile updated!", brandGreen);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  // --- UI COMPONENTS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentGold));
          }
          if (snapshot.hasError)
            return _buildErrorState(snapshot.error.toString());

          final userData = snapshot.data!;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(userData),
              SliverToBoxAdapter(child: _buildListMenu(userData)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> userData) {
    String name =
        "${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}".trim();
    if (name.isEmpty) name = userData['username'] ?? "Skyport User";

    return SliverAppBar(
      expandedHeight: 220,
      backgroundColor: primaryDark,
      pinned: true,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(35))),
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Stack(
                  children: [
                    _buildAvatar(userData['profile_picture']),
                    Positioned(bottom: 0, right: 0, child: _buildCamBtn()),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome back,",
                          style: TextStyle(
                              color: accentGold,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900)),
                      Text(userData['phone_number'] ?? "Add Phone",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.edit_note, color: accentGold, size: 30),
                    onPressed: () => _showEditSheet(userData)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? url) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: accentGold, width: 2)),
      child: CircleAvatar(
        radius: 38,
        backgroundColor: Colors.grey[800],
        backgroundImage:
            (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
        child: (url == null || url.isEmpty)
            ? const Icon(Icons.person, size: 40, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildCamBtn() {
    return GestureDetector(
      onTap: _showPickOptions,
      child: CircleAvatar(
          radius: 14,
          backgroundColor: accentGold,
          child: const Icon(Icons.camera_alt, size: 14, color: Colors.black)),
    );
  }

  Widget _buildListMenu(Map<String, dynamic> userData) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _menuItem(Icons.flight_takeoff, "Post a New Trip", const PostTripPage(),
            accentGold),
        _menuItem(Icons.local_shipping, "Request Shipping",
            const PostProductRequest(), Colors.blueAccent),
        _menuItem(
            Icons.sell, "Add Product", const ProductShowroom(), brandGreen),
        const Divider(height: 40, indent: 25, endIndent: 25),
        _menuItem(Icons.history, "My Listings", const CustomerActivityList(),
            primaryDark),
        _menuItem(Icons.logout, "Logout", null, Colors.redAccent,
            isLogout: true),
        const SizedBox(height: 40),
        const Text("SKYPORT v1.0.0",
            style: TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _menuItem(IconData icon, String label, Widget? dest, Color col,
      {bool isLogout = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: col.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: col)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: isLogout
          ? _handleLogout
          : () {
              if (dest != null)
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => dest));
            },
    );
  }

  // --- STANDARD HELPERS ---

  void _showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            Center(child: CircularProgressIndicator(color: accentGold)));
  }

  void _showSnackBar(String m, Color c) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m), backgroundColor: c));
  }

  Future<void> _handleLogout() async {
    await storage.deleteAll();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (r) => false);
  }

  void _showEditSheet(Map<String, dynamic> d) {
    final f = TextEditingController(text: d['first_name']);
    final l = TextEditingController(text: d['last_name']);
    final p = TextEditingController(text: d['phone_number']);
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: f,
                  decoration: const InputDecoration(labelText: "First Name")),
              TextField(
                  controller: l,
                  decoration: const InputDecoration(labelText: "Last Name")),
              TextField(
                  controller: p,
                  decoration: const InputDecoration(labelText: "Phone")),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateProfileText(f.text, l.text, p.text);
                  },
                  child: const Text("Save")),
              const SizedBox(height: 20)
            ])));
  }

  Widget _buildErrorState(String e) => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error),
        Text(e),
        TextButton(
            onPressed: () => setState(() {
                  _userDataFuture = _fetchUserData();
                }),
            child: const Text("Retry"))
      ]));
}
