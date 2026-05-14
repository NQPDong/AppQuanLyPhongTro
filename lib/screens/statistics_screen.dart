import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// If PDF export takes too long to write, I'll mock it for now according to user's "nếu có thời gian".
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../services/invoice_service.dart';
import '../services/room_service.dart';
import '../services/contract_service.dart';
import '../models/invoice.dart';
import '../models/room.dart';
import '../models/contract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedYear = DateTime.now().year.toString();
  final InvoiceService _invoiceService = InvoiceService();
  final RoomService _roomService = RoomService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Invoice>>(
      stream: _invoiceService.getAllInvoices(),
      builder: (context, invoiceSnapshot) {
        return StreamBuilder<List<Room>>(
          stream: FirebaseFirestore.instance.collection('rooms')
              .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .snapshots()
              .map((s) => s.docs.map((d) => Room.fromMap(d.data() as Map<String, dynamic>, d.id)).toList()),
          builder: (context, roomSnapshot) {
            if (!invoiceSnapshot.hasData || !roomSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final invoices = invoiceSnapshot.data!;
            final rooms = roomSnapshot.data!;

            // 1. Tính toán doanh thu 12 tháng của năm được chọn
            List<double> monthlyRevenue = List.filled(12, 0.0);
            for (var inv in invoices) {
              if (inv.year.toString() == selectedYear && inv.isPaid) {
                monthlyRevenue[inv.month - 1] += inv.totalAmount;
              }
            }
            double maxRevenue = monthlyRevenue.reduce((a, b) => a > b ? a : b);
            if (maxRevenue == 0) maxRevenue = 1000000; // Mặc định để tránh lỗi chia cho 0

            // 2. Tính toán tỉ lệ phòng
            int rentedCount = rooms.where((r) => r.status == 'rented').length;
            int availableCount = rooms.where((r) => r.status == 'available').length;
            int totalRooms = rooms.isEmpty ? 1 : rooms.length;
            double rentedPercent = (rentedCount / totalRooms) * 100;
            double availablePercent = (availableCount / totalRooms) * 100;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: kToolbarHeight + 20),
                  // Filter Row & PDF
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        const Text(
                          'Báo cáo thống kê',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedYear,
                                  items: ['2023', '2024', '2025', '2026'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value, style: const TextStyle(fontSize: 14)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => selectedYear = val);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _exportPdf(monthlyRevenue, rentedCount, availableCount),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.download_rounded, size: 20),
                              label: const Text('Xuất PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Card Biểu đồ cột
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Doanh thu 12 tháng (VNĐ)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildChartLegend('Đã thu', const Color(0xFF6366F1)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxRevenue * 1.2,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (_) => const Color(0xFF1E293B),
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        '${rod.toY.toStringAsFixed(0)}đ',
                                        const TextStyle(color: Colors.white),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        const style = TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 10);
                                        String text = 'T${value.toInt() + 1}';
                                        if (value.toInt() % 2 != 0) text = ''; // Chỉ hiện tháng lẻ cho đỡ chật
                                        return SideTitleWidget(meta: meta, space: 4, child: Text(text, style: style));
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(12, (index) {
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: monthlyRevenue[index], 
                                        color: const Color(0xFF6366F1),
                                        width: 14,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tỉ lệ phòng trống / đã thuê (Pie chart)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Tỉ lệ lấp đầy phòng',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 200,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 30,
                                sections: [
                                  PieChartSectionData(
                                    color: const Color(0xFF6366F1),
                                    value: rentedCount.toDouble(),
                                    title: '${rentedPercent.toStringAsFixed(0)}%',
                                    radius: 40,
                                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xFFCBD5E1),
                                    value: availableCount.toDouble(),
                                    title: '${availablePercent.toStringAsFixed(0)}%',
                                    radius: 40,
                                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildChartLegend('Đã thuê ($rentedCount)', const Color(0xFF6366F1)),
                              const SizedBox(height: 8),
                              _buildChartLegend('Còn trống ($availableCount)', const Color(0xFFCBD5E1)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Hoạt động gần đây (Hóa đơn)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      if (invoices.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text('Chưa có hoạt động nào', style: TextStyle(color: Color(0xFF64748B)))),
                        );
                      }
                      
                      final recentInvoices = invoices.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      final top5Recent = recentInvoices.take(5).toList();
                      
                      return Column(
                        children: top5Recent.map((inv) {
                          String roomName = 'Phòng đã xóa';
                          try {
                            final room = rooms.firstWhere((r) => r.id == inv.roomId);
                            roomName = 'Phòng ${room.roomNumber}';
                          } catch (_) {}
                          
                          return _buildTenantItem(
                            'Hóa đơn T${inv.month}/${inv.year} - $roomName',
                            inv.isPaid ? 'Đã thu' : 'Chưa thu',
                            inv.isPaid ? 1.0 : 0.5,
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildTenantItem(String name, String room, double value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text(room, style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: const Color(0xFFF1F5F9),
                color: const Color(0xFF6366F1),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _exportPdf(List<double> monthlyRevenue, int rentedCount, int availableCount) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: fontBold,
      ),
    );

    double totalRevenue = monthlyRevenue.fold(0, (sum, val) => sum + val);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('BÁO CÁO THỐNG KÊ - NĂM $selectedYear', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('1. TỔNG QUAN DOANH THU', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Tổng doanh thu trong năm $selectedYear: ${totalRevenue.toStringAsFixed(0)} VNĐ', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
              pw.Text('Doanh thu theo từng tháng:'),
              ...List.generate(12, (index) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 10, top: 4),
                  child: pw.Text('- Tháng ${index + 1}: ${monthlyRevenue[index].toStringAsFixed(0)} VNĐ'),
                );
              }),
              pw.SizedBox(height: 20),
              pw.Text('2. TÌNH TRẠNG PHÒNG', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Tổng số phòng: ${rentedCount + availableCount} phòng'),
              pw.Text('- Đã cho thuê: $rentedCount phòng'),
              pw.Text('- Đang trống: $availableCount phòng'),
              pw.SizedBox(height: 30),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Ngày xuất báo cáo: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Bao_Cao_Thong_Ke_$selectedYear.pdf',
    );
  }
}
