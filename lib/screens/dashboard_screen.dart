import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'contracts_screen.dart';
import 'contract_details_screen.dart';
import '../services/contract_service.dart';
import '../services/invoice_service.dart';
import '../services/room_service.dart';
import '../models/contract.dart';
import '../models/invoice.dart';
import '../models/room.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final ContractService _contractService = ContractService();
  final InvoiceService _invoiceService = InvoiceService();
  final RoomService _roomService = RoomService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Admin';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: kToolbarHeight + 20),
          // Chào hỏi người dùng
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF), // Màu nền phân biệt (tím nhạt)
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE0E7FF), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chào buổi sáng,',
                        style: TextStyle(color: Color(0xFF6366F1), fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$displayName 👋',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.person_rounded, color: Color(0xFF6366F1), size: 28),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Widget Thống kê Bento
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: StreamBuilder<List<Invoice>>(
                    stream: _invoiceService.getAllInvoices(),
                    builder: (context, snapshot) {
                      double revenue = 0;
                      if (snapshot.hasData) {
                        revenue = snapshot.data!
                            .where((inv) => inv.isPaid)
                            .fold(0, (sum, inv) => sum + inv.totalAmount);
                      }
                      return _buildFeaturedCard(
                        'Tổng doanh thu',
                        '${revenue.toStringAsFixed(0)}đ',
                        Icons.account_balance_wallet_rounded,
                        const Color(0xFF6366F1),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<List<Room>>(
                    // Giả sử ta lấy tất cả phòng để đếm, thực tế nên có hàm count riêng
                    // Tạm thời ta lấy phòng theo property (cần loop qua các property hoặc có service lấy hết)
                    // Vì chưa có service lấy hết phòng của user, ta dùng tạm logic này hoặc bổ sung service
                    stream: FirebaseFirestore.instance.collection('rooms')
                        .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                        .snapshots()
                        .map((s) => s.docs.map((d) => Room.fromMap(d.data() as Map<String, dynamic>, d.id)).toList()),
                    builder: (context, snapshot) {
                      int available = 0;
                      int maintenance = 0;
                      if (snapshot.hasData) {
                        available = snapshot.data!.where((r) => r.status == 'available').length;
                        maintenance = snapshot.data!.where((r) => r.status == 'maintenance').length;
                      }
                      return Column(
                        children: [
                          _buildSmallCard('Phòng trống', '$available', const Color(0xFF10B981)),
                          const SizedBox(height: 12),
                          _buildSmallCard('Bảo trì', '$maintenance', const Color(0xFFF59E0B)),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Tiêu đề danh sách
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hợp đồng mới nhất',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContractsScreen()),
                    );
                  }, 
                  child: const Text('Xem tất cả')
                ),
              ],
            ),
          ),
          // Danh sách hợp đồng
          StreamBuilder<List<Contract>>(
            stream: _contractService.getContracts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
              }
              
              final contracts = snapshot.data?.take(4).toList() ?? [];

              if (contracts.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Chưa có hợp đồng nào.', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: contracts.length,
                itemBuilder: (context, index) {
                  final contract = contracts[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ContractDetailsScreen(contract: contract)),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.description_rounded, color: Color(0xFF6366F1)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contract.code.isNotEmpty ? 'Hợp đồng ${contract.code}' : 'Hợp đồng mới',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  'Tiền cọc: ${contract.depositAmount.toStringAsFixed(0)}đ • ${contract.status}',
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          ),
          const SizedBox(height: 100), // Khoảng trống cho BottomNav
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSmallCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
