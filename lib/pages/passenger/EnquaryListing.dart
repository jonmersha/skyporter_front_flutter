import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/api_constants.dart';

class EnquiryListPage extends StatefulWidget {
  const EnquiryListPage({super.key});

  @override
  State<EnquiryListPage> createState() => _EnquiryListPageState();
}

class _EnquiryListPageState extends State<EnquiryListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final storage = const FlutterSecureStorage();
  List<dynamic> _inbox = [];
  List<dynamic> _sent = [];
  bool _isLoading = true;

  // Skyport Brand Palette
  final Color primaryDark = const Color(0xFF1A1A1A);
  final Color accentGold = const Color(0xFFECAE0B);
  final Color brandGreen = const Color(0xFF089348);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchEnquiries();
  }

  Future<void> _fetchEnquiries() async {
    String? token = await storage.read(key: 'access');
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
        headers: ApiConstants.authHeader(token ?? ""),
      );
      if (response.statusCode == 200) {
        final List<dynamic> allData = jsonDecode(response.body);

        // Assuming your API returns current_user_role or similar
        // For now, we simulate sorting by sender/receiver
        setState(() {
          _inbox = allData.where((item) => item['is_receiver'] == true).toList();
          _sent = allData.where((item) => item['is_receiver'] == false).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("MESSAGES",
            style: TextStyle(color: primaryDark, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentGold,
          labelColor: primaryDark,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          tabs: const [Tab(text: "INBOX"), Tab(text: "SENT")],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentGold))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildList(items: _inbox, isInbox: true),
          _buildList(items: _sent, isInbox: false),
        ],
      ),
    );
  }

  Widget _buildList({required List<dynamic> items, required bool isInbox}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline_rounded, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("No enquiries yet", style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchEnquiries,
      color: accentGold,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final bool isAccepted = item['is_accepted'] ?? false;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: primaryDark,
                child: Text(
                  (isInbox ? item['sender_name'] : item['receiver_name'])[0].toUpperCase(),
                  style: TextStyle(color: accentGold, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                isInbox ? item['sender_name'] : item['receiver_name'],
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(item['message'], maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAccepted ? brandGreen.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isAccepted ? "DEAL ACCEPTED" : "PENDING RESPONSE",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isAccepted ? brandGreen : Colors.orange.shade800
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () => _showEnquiryDetail(item),
            ),
          );
        },
      ),
    );
  }

  void _showEnquiryDetail(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Enquiry Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primaryDark)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 15),
            Text("FROM", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            Text(item['sender_name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Text("MESSAGE", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            Text(item['message'], style: const TextStyle(fontSize: 15, height: 1.5)),
            const SizedBox(height: 30),
            if (item['is_accepted'] == false && item['is_receiver'] == true)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () => _acceptEnquiry(item['id']),
                  child: const Text("ACCEPT DEAL & SECURE SHIPPING", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptEnquiry(int id) async {
    String? token = await storage.read(key: 'access');
    try {
      final response = await http.patch(
        Uri.parse("${ApiConstants.baseUrl}/api/enquiries/$id/"),
        headers: ApiConstants.authHeader(token ?? ""),
        body: jsonEncode({"is_accepted": true}),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        _fetchEnquiries(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text("Deal successfully accepted!"), backgroundColor: brandGreen)
        );
      }
    } catch (e) {
      debugPrint("Accept error: $e");
    }
  }
}