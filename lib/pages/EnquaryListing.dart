import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/api_constants.dart';

class EnquiryListPage extends StatefulWidget {
  const EnquiryListPage({super.key});

  @override
  State<EnquiryListPage> createState() => _EnquiryListPageState();
}

class _EnquiryListPageState extends State<EnquiryListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final storage = const FlutterSecureStorage();
  List<dynamic> _enquiries = [];
  bool _isLoading = true;

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
        headers: ApiConstants.authHeader(token!),
      );
      if (response.statusCode == 200) {
        setState(() {
          _enquiries = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages & Enquiries"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "Inbox"), Tab(text: "Sent")],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(isInbox: true),
                _buildList(isInbox: false),
              ],
            ),
    );
  }

  Widget _buildList({required bool isInbox}) {
    // Filter enquiries based on current user role (Simplified logic)
    // In a real app, you'd check 'item[sender]' against your local user ID
    final filtered = _enquiries;

    if (filtered.isEmpty) {
      return const Center(child: Text("No messages here yet."));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(isInbox
              ? "From: ${item['sender_name']}"
              : "To: ${item['receiver_name']}"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['message'],
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(item['enquiry_type'] ?? "General",
                  style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
            ],
          ),
          trailing: item['is_accepted']
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.pending_actions, color: Colors.orange),
          onTap: () => _showEnquiryDetail(item),
        );
      },
    );
  }

  void _showEnquiryDetail(dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Message from ${item['sender_name']}"),
        content: Text(item['message']),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
          if (item['is_accepted'] == false)
            ElevatedButton(
              onPressed: () => _acceptEnquiry(item['id']),
              child: const Text("Accept Deal"),
            ),
        ],
      ),
    );
  }

  Future<void> _acceptEnquiry(int id) async {
    // Implement the PATCH request to /api/enquiries/id/ to set is_accepted = true
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Deal Accepted!")));
  }
}
