import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contract.dart';
import '../services/contract_service.dart';
import 'invoices_screen.dart';

class ContractDetailsScreen extends StatelessWidget {
  final Contract contract;
  const ContractDetailsScreen({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    final ContractService _contractService = ContractService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Chi tiết Hợp đồng'),
        backgroundColor: Colors.white,
        actions: [
          if (contract.status == 'active')
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận thanh lý'),
                    content: const Text('Bạn có chắc muốn thanh lý hợp đồng này và trả phòng về trạng thái Trống?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xác nhận')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _contractService.terminateContract(contract.id, contract.roomId);
                  Navigator.pop(context);
                }
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thẻ trạng thái
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: contract.status == 'active' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                contract.status == 'active' ? 'ĐANG HIỆU LỰC' : 'ĐÃ KẾT THÚC',
                style: TextStyle(
                  color: contract.status == 'active' ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoSection('Thông tin thuê', [
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('rooms').doc(contract.roomId).get(),
                builder: (context, snapshot) {
                  String val = 'Đang tải...';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    val = 'Phòng ${snapshot.data!['roomNumber']}';
                  }
                  return _buildInfoRow(Icons.meeting_room_rounded, 'Phòng', val);
                },
              ),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('tenants').doc(contract.tenantId).get(),
                builder: (context, snapshot) {
                  String val = 'Đang tải...';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data != null) {
                      final code = data['code']?.toString() ?? '';
                      final name = data['fullName']?.toString() ?? '';
                      val = code.isNotEmpty ? '$code - $name' : name;
                    }
                  }
                  return _buildInfoRow(Icons.person_rounded, 'Khách thuê', val);
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildInfoSection('Thời hạn & Tài chính', [
              _buildInfoRow(Icons.calendar_today_rounded, 'Ngày bắt đầu', '${contract.startDate.day}/${contract.startDate.month}/${contract.startDate.year}'),
              _buildInfoRow(Icons.event_busy_rounded, 'Ngày kết thúc', '${contract.endDate.day}/${contract.endDate.month}/${contract.endDate.year}'),
              _buildInfoRow(Icons.payments_rounded, 'Tiền đặt cọc', '${contract.depositAmount.toStringAsFixed(0)}đ'),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InvoicesScreen(contract: contract)),
                  );
                },
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Xem hóa đơn hàng tháng', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}
