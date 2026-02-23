import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyporters/utils/api_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDealsPage extends StatefulWidget {
  const MyDealsPage({super.key});

  @override
  State<MyDealsPage> createState() => _MyDealsPageState();
}

class _MyDealsPageState extends State<MyDealsPage> {
  final storage = const FlutterSecureStorage();
  late Future<List<dynamic>> _enquiriesFuture;
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _enquiriesFuture = _fetchEnquiries();
  }

  /// Fetches data and updates the local user ID for role logic
  Future<List<dynamic>> _fetchEnquiries() async {
    String? token = await storage.read(key: 'access');
    _myUserId = await storage.read(key: 'user_id');

    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/enquiries/"),
      headers: {
        'accept': 'application/json',
        'Authorization': 'JWT $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load enquiries: ${response.statusCode}");
    }
  }

  /// Triggered by the RefreshIndicator or the AppBar button
  Future<void> _handleRefresh() async {
    setState(() {
      _enquiriesFuture = _fetchEnquiries();
    });
    // Wait for the future to complete so the refresh spinner disappears correctly
    await _enquiriesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          "My Enquiries",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _handleRefresh,
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _enquiriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFECAE0B)));
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final enquiries = snapshot.data!;

          return RefreshIndicator(
            color: const Color(0xFF089348),
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: enquiries.length,
              // Physics ensures it's always scrollable even if short (for pull-to-refresh)
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildEnquiryCard(enquiries[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnquiryCard(Map<String, dynamic> data) {
    final bool isIAmSender = data['sender'].toString() == _myUserId;
    final bool isAccepted = data['is_accepted'] ?? false;
    final Color statusColor = isAccepted ? const Color(0xFF089348) : Colors.orange.shade800;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Role Header Strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: isIAmSender ? Colors.blue.withOpacity(0.1) : const Color(0xFF089348).withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Text(
              isIAmSender ? "SENT REQUEST" : "INCOMING ENQUIRY",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isIAmSender ? Colors.blue.shade800 : const Color(0xFF089348)),
            ),
          ),

          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
            title: Text(
              data['message'] ?? "No message detail",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              isIAmSender ? "To: ${data['receiver_full_name']}" : "From: ${data['sender_full_name']}",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: Icon(isAccepted ? Icons.check_circle : Icons.pending_actions, color: statusColor),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(isAccepted ? "ACCEPTED" : "PENDING", statusColor),
                Text(
                  data['created_at'].toString().substring(0, 10),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action Row
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                if (!isIAmSender && !isAccepted)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _handleStatusUpdate(data['id'], true),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("ACCEPT", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF089348)),
                    ),
                  ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _launchPhone(data['receiver_phone']),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text("CALL", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          const Center(child: Icon(Icons.inbox_outlined, size: 80, color: Colors.grey)),
          const SizedBox(height: 16),
          const Center(child: Text("No enquiries found", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          const Center(child: Text("Pull down to refresh", style: TextStyle(color: Colors.grey, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 10),
            Text("Connection Error: $error", textAlign: TextAlign.center),
            TextButton(onPressed: _handleRefresh, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }

  void _launchPhone(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri url = Uri.parse('tel:$phone');
    if (!await launchUrl(url)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open dialer")));
    }
  }

  Future<void> _handleStatusUpdate(int id, bool accept) async {
    // Logic for PATCHing would go here
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Processing enquiry #$id...")));
    // Re-fetch data after update
    _handleRefresh();
  }
}