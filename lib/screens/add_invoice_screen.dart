import 'package:flutter/material.dart';
import '../models/contract.dart';
import '../models/invoice.dart';
import '../models/room.dart';
import '../services/invoice_service.dart';
import '../services/room_service.dart';
import '../services/auth_service.dart';
import '../services/api_config.dart';

class AddInvoiceScreen extends StatefulWidget {
  final Contract contract;
  const AddInvoiceScreen({super.key, required this.contract});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _oldElecController = TextEditingController();
  final _newElecController = TextEditingController();
  final _peopleController = TextEditingController(text: '1');

  final double elecPrice = 3500;
  final double waterPrice = 60000; // 60k per head

  bool _hasGarbage = true;
  bool _hasWifi = true;

  Room? _room;
  bool _isLoadingRoom = true;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _loadRoomDetails();
  }

  Future<void> _loadRoomDetails() async {
    try {
      final room = await RoomService().getRoomById(widget.contract.roomId);
      if (mounted) {
        setState(() {
          _room = room;
          _isLoadingRoom = false;
        });
        _calculateTotal();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRoom = false;
        });
      }
    }
  }

  void _calculateTotal() {
    if (_room == null) return;

    double oldE = double.tryParse(_oldElecController.text) ?? 0;
    double newE = double.tryParse(_newElecController.text) ?? 0;
    double people = double.tryParse(_peopleController.text) ?? 0;

    double elecTotal = 0;
    if (newE > oldE) {
      elecTotal = (newE - oldE) * elecPrice;
    }

    double waterTotal = people * waterPrice;

    double sFee = 0;
    if (_hasGarbage) sFee += 50000;
    if (_hasWifi) sFee += 170000;

    setState(() {
      _total = _room!.price + elecTotal + waterTotal + sFee;
    });
  }

  String _formatCurrency(double amount) {
    return ApiConfig.formatVND(amount);
  }

  @override
  void dispose() {
    _oldElecController.dispose();
    _newElecController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRoom) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tạo hóa đơn'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    if (_room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tạo hóa đơn')),
        body: const Center(
          child: Text('Không tìm thấy thông tin phòng trọ.', style: TextStyle(color: Colors.red)),
        ),
      );
    }

    double oldE = double.tryParse(_oldElecController.text) ?? 0;
    double newE = double.tryParse(_newElecController.text) ?? 0;
    double people = double.tryParse(_peopleController.text) ?? 0;
    double elecTotal = (newE > oldE) ? (newE - oldE) * elecPrice : 0;
    double waterTotal = people * waterPrice;
    double sFee = (_hasGarbage ? 50000.0 : 0.0) + (_hasWifi ? 170000.0 : 0.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Tạo Hóa Đơn'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hóa đơn Tháng ${DateTime.now().month}/${DateTime.now().year}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.receipt_long_rounded, color: Colors.white70, size: 28),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    'Mã hợp đồng: ${widget.contract.code.isNotEmpty ? widget.contract.code : widget.contract.id}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phòng: ${_room!.roomNumber} • Giá phòng: ${_formatCurrency(_room!.price)}',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tiền Điện Card
            _buildSectionCard(
              title: 'TIỀN ĐIỆN (CHỈ SỐ)',
              icon: Icons.electric_bolt_rounded,
              iconColor: const Color(0xFFF59E0B),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _oldElecController,
                          label: 'Chỉ số cũ',
                          icon: Icons.keyboard_double_arrow_left_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _newElecController,
                          label: 'Chỉ số mới',
                          icon: Icons.keyboard_double_arrow_right_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Đơn giá: ${_formatCurrency(elecPrice)}/kWh',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  if (newE > oldE) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tiêu thụ: ${(newE - oldE).toStringAsFixed(0)} kWh  •  Thành tiền: ${_formatCurrency(elecTotal)}',
                      style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tiền Nước Card
            _buildSectionCard(
              title: 'TIỀN NƯỚC (ĐẦU NGƯỜI)',
              icon: Icons.water_drop_rounded,
              iconColor: const Color(0xFF0EA5E9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _peopleController,
                    label: 'Số người sử dụng nước',
                    icon: Icons.people_alt_rounded,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Đơn giá: ${_formatCurrency(waterPrice)}/người',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  if (people > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Thành tiền: ${_formatCurrency(waterTotal)}',
                      style: const TextStyle(color: Color(0xFF0EA5E9), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dịch Vụ Card
            _buildSectionCard(
              title: 'DỊCH VỤ (TÙY CHỌN)',
              icon: Icons.room_service_rounded,
              iconColor: const Color(0xFF10B981),
              child: Column(
                children: [
                  _buildCheckboxTile(
                    title: 'Tiền rác',
                    subtitle: '${ApiConfig.formatVND(50000)} / phòng',
                    value: _hasGarbage,
                    onChanged: (val) {
                      setState(() {
                        _hasGarbage = val ?? false;
                        _calculateTotal();
                      });
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  _buildCheckboxTile(
                    title: 'Tiền Wifi',
                    subtitle: '${ApiConfig.formatVND(170000)} / phòng',
                    value: _hasWifi,
                    onChanged: (val) {
                      setState(() {
                        _hasWifi = val ?? false;
                        _calculateTotal();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tổng Hợp Hóa Đơn Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CHI TIẾT HÓA ĐƠN',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF475569), letterSpacing: 1),
                  ),
                  const SizedBox(height: 16),
                  _buildBillRow('Tiền phòng', _formatCurrency(_room!.price)),
                  _buildBillRow('Tiền điện', _formatCurrency(elecTotal)),
                  _buildBillRow('Tiền nước', _formatCurrency(waterTotal)),
                  _buildBillRow('Tiền dịch vụ', _formatCurrency(sFee)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFCBD5E1)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TỔNG CỘNG',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      Text(
                        _formatCurrency(_total),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF6366F1)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Nút Lưu Hóa Đơn
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final invoice = Invoice(
                    id: '',
                    ownerId: AuthService.currentUser!.uid,
                    contractId: widget.contract.id,
                    roomId: widget.contract.roomId,
                    tenantId: widget.contract.tenantId,
                    month: DateTime.now().month,
                    year: DateTime.now().year,
                    oldElec: double.tryParse(_oldElecController.text) ?? 0,
                    newElec: double.tryParse(_newElecController.text) ?? 0,
                    elecPrice: elecPrice,
                    oldWater: double.tryParse(_peopleController.text) ?? 0, // Số người
                    newWater: 0.0,
                    waterPrice: waterPrice,
                    serviceFee: sFee,
                    totalAmount: _total,
                    createdAt: DateTime.now(),
                  );
                  try {
                    await InvoiceService().createInvoice(invoice);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tạo hóa đơn thành công!'), backgroundColor: Colors.green),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'LƯU HÓA ĐƠN',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) => _calculateTotal(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
      activeColor: const Color(0xFF6366F1),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
