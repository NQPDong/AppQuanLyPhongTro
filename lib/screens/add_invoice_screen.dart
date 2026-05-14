import 'package:flutter/material.dart';
import '../models/contract.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddInvoiceScreen extends StatefulWidget {
  final Contract contract;
  const AddInvoiceScreen({super.key, required this.contract});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _oldElecController = TextEditingController();
  final _newElecController = TextEditingController();
  final _oldWaterController = TextEditingController();
  final _newWaterController = TextEditingController();
  final _serviceFeeController = TextEditingController(text: '0');
  
  final double elecPrice = 3500;
  final double waterPrice = 15000;
  
  double _total = 0;

  void _calculateTotal() {
    double oldE = double.tryParse(_oldElecController.text) ?? 0;
    double newE = double.tryParse(_newElecController.text) ?? 0;
    double oldW = double.tryParse(_oldWaterController.text) ?? 0;
    double newW = double.tryParse(_newWaterController.text) ?? 0;
    double sFee = double.tryParse(_serviceFeeController.text) ?? 0;

    double elecTotal = (newE - oldE) * elecPrice;
    double waterTotal = (newW - oldW) * waterPrice;
    
    setState(() {
      _total = elecTotal + waterTotal + sFee;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo hóa đơn')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Hóa đơn cho hợp đồng ${widget.contract.id}'),
            const SizedBox(height: 16),
            TextField(controller: _oldElecController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số điện cũ'), onChanged: (_) => _calculateTotal()),
            TextField(controller: _newElecController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số điện mới'), onChanged: (_) => _calculateTotal()),
            TextField(controller: _oldWaterController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số nước cũ'), onChanged: (_) => _calculateTotal()),
            TextField(controller: _newWaterController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số nước mới'), onChanged: (_) => _calculateTotal()),
            TextField(controller: _serviceFeeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Phí dịch vụ'), onChanged: (_) => _calculateTotal()),
            const SizedBox(height: 24),
            Text('Tổng cộng: $_total VNĐ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final invoice = Invoice(
                  id: '',
                  ownerId: FirebaseAuth.instance.currentUser!.uid,
                  contractId: widget.contract.id,
                  roomId: widget.contract.roomId,
                  tenantId: widget.contract.tenantId,
                  month: DateTime.now().month,
                  year: DateTime.now().year,
                  oldElec: double.parse(_oldElecController.text),
                  newElec: double.parse(_newElecController.text),
                  elecPrice: elecPrice,
                  oldWater: double.parse(_oldWaterController.text),
                  newWater: double.parse(_newWaterController.text),
                  waterPrice: waterPrice,
                  serviceFee: double.parse(_serviceFeeController.text),
                  totalAmount: _total,
                  createdAt: DateTime.now(),
                );
                await InvoiceService().createInvoice(invoice);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Lưu hóa đơn'),
            )
          ],
        ),
      ),
    );
  }
}
