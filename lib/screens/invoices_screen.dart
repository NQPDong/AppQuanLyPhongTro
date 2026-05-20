import 'package:flutter/material.dart';
import '../models/contract.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';
import 'add_invoice_screen.dart';

class InvoicesScreen extends StatefulWidget {
  final Contract contract;
  const InvoicesScreen({super.key, required this.contract});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final InvoiceService _invoiceService = InvoiceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hóa đơn hàng tháng')),
      body: StreamBuilder<List<Invoice>>(
        stream: _invoiceService.getInvoicesByContract(widget.contract.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final invoices = snapshot.data!;
          if (invoices.isEmpty) return const Center(child: Text('Chưa có hóa đơn nào'));

          return ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Tháng ${invoice.month}/${invoice.year}'),
                  subtitle: Text('Tổng tiền: ${invoice.totalAmount}đ'),
                  trailing: invoice.isPaid 
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : ElevatedButton(
                        onPressed: () => _invoiceService.markAsPaid(invoice.id),
                        child: const Text('Thanh toán'),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
