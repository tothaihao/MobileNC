import 'package:flutter/material.dart';
import '../../services/admin_support_request_service.dart';

class SupportRequestPage extends StatefulWidget {
  const SupportRequestPage({Key? key}) : super(key: key);

  @override
  State<SupportRequestPage> createState() => _SupportRequestPageState();
}

class _SupportRequestPageState extends State<SupportRequestPage> {
  final AdminSupportRequestService _service = AdminSupportRequestService();
  List<Map<String, dynamic>> requests = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => isLoading = true);
    try {
      final data = await _service.fetchRequests();
      setState(() => requests = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải support request: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => isLoading = false);
  }

  void _openRequest(Map<String, dynamic> request) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupportRequestDetailPage(requestId: request['id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Support Request')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return ListTile(
                  leading: const Icon(Icons.support_agent),
                  title: Text(request['userName'] ?? ''),
                  subtitle: Text(request['message'] ?? ''),
                  trailing: Text(request['status'] ?? ''),
                  onTap: () => _openRequest(request),
                );
              },
            ),
    );
  }
}

class SupportRequestDetailPage extends StatefulWidget {
  final String requestId;
  const SupportRequestDetailPage({Key? key, required this.requestId}) : super(key: key);

  @override
  State<SupportRequestDetailPage> createState() => _SupportRequestDetailPageState();
}

class _SupportRequestDetailPageState extends State<SupportRequestDetailPage> {
  final AdminSupportRequestService _service = AdminSupportRequestService();
  Map<String, dynamic>? requestDetail;
  bool isLoading = false;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchRequestDetail();
  }

  Future<void> _fetchRequestDetail() async {
    setState(() => isLoading = true);
    try {
      final data = await _service.fetchRequestDetail(widget.requestId);
      setState(() {
        requestDetail = data;
        selectedStatus = data['status'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải chi tiết support request: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _updateStatus() async {
    if (selectedStatus == null) return;
    final success = await _service.updateRequestStatus(widget.requestId, selectedStatus!);
    if (success) {
      _fetchRequestDetail();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái thành công!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái thất bại!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết Support Request')),
      body: isLoading || requestDetail == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Người gửi: ${requestDetail!['userName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Email: ${requestDetail!['userEmail'] ?? ''}'),
                  const SizedBox(height: 8),
                  Text('Nội dung: ${requestDetail!['message'] ?? ''}'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: const [
                      DropdownMenuItem(value: 'pending', child: Text('Chờ xử lý')),
                      DropdownMenuItem(value: 'in_progress', child: Text('Đang xử lý')),
                      DropdownMenuItem(value: 'resolved', child: Text('Đã xử lý')),
                    ],
                    onChanged: (v) => setState(() => selectedStatus = v),
                    decoration: const InputDecoration(
                      labelText: 'Trạng thái',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateStatus,
                      child: const Text('Cập nhật trạng thái'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 