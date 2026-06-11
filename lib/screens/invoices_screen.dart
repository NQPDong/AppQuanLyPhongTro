import 'package:flutter/material.dart';
import '../models/contract.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';
import '../services/room_service.dart';
import 'add_invoice_screen.dart';
import '../services/api_config.dart';
import '../services/auth_service.dart';

class InvoicesScreen extends StatefulWidget {
  final Contract contract;
  const InvoicesScreen({super.key, required this.contract});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  String _roomNumber = '...';


  @override
  void initState() {
    super.initState();
    _loadRoomInfo();
  }

  Future<void> _loadRoomInfo() async {
    try {
      final room = await RoomService().getRoomById(widget.contract.roomId);
      if (room != null && mounted) {
        setState(() {
          _roomNumber = room.roomNumber;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  String _formatCurrency(double amount) {
    return ApiConfig.formatVND(amount);
  }

  @override
  Widget build(BuildContext context) {
    String contractTitle = widget.contract.code.isNotEmpty ? widget.contract.code : widget.contract.id.substring(0, 8);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Hóa Đơn - Phòng $_roomNumber'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Invoice>>(
        stream: _invoiceService.getInvoicesByContract(widget.contract.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final invoices = snapshot.data ?? [];
          if (invoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_rounded, size: 72, color: Color(0xFFCBD5E1)),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có hóa đơn nào',
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hợp đồng: $contractTitle',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              
              // Tính toán chi tiết
              double elecTotal = (invoice.newElec > invoice.oldElec) ? (invoice.newElec - invoice.oldElec) * invoice.elecPrice : 0;
              double waterTotal = invoice.oldWater * invoice.waterPrice;
              double roomPrice = invoice.totalAmount - elecTotal - waterTotal - invoice.serviceFee;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.black.withOpacity(0.05)),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: invoice.isPaid ? const Color(0xFFEEF2FF) : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        color: invoice.isPaid ? const Color(0xFF6366F1) : const Color(0xFFF59E0B),
                      ),
                    ),
                    title: Text(
                      'Tháng ${invoice.month}/${invoice.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                    ),
                    subtitle: Text(
                      'Tổng: ${_formatCurrency(invoice.totalAmount)}',
                      style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: invoice.isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            invoice.isPaid ? 'Đã thu' : 'Chưa thu',
                            style: TextStyle(
                              color: invoice.isPaid ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.expand_more_rounded, color: Color(0xFF94A3B8)),
                      ],
                    ),
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CHI TIẾT THANH TOÁN',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow('Tiền phòng (cố định)', _formatCurrency(roomPrice)),
                            _buildDetailRow(
                              'Tiền điện (chỉ số: ${invoice.oldElec.toStringAsFixed(0)} - ${invoice.newElec.toStringAsFixed(0)})',
                              _formatCurrency(elecTotal),
                            ),
                            _buildDetailRow(
                              'Tiền nước (${invoice.oldWater.toStringAsFixed(0)} người)',
                              _formatCurrency(waterTotal),
                            ),
                            _buildDetailRow('Tiền dịch vụ (Rác, Wifi)', _formatCurrency(invoice.serviceFee)),
                            const Divider(height: 20, color: Color(0xFFF1F5F9)),
                            
                            // Nút hành động thanh toán
                            if (!invoice.isPaid)
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      await _invoiceService.markAsPaid(invoice.id);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Xác nhận thanh toán thành công!'), backgroundColor: Colors.green),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.check_rounded),
                                  label: const Text('XÁC NHẬN THANH TOÁN', style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddInvoiceScreen(contract: widget.contract)),
                );
              },
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
