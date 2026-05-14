import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/invoice.dart';

class InvoiceService {
  final CollectionReference _invoicesCollection = FirebaseFirestore.instance.collection('invoices');
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Lấy danh sách hóa đơn theo hợp đồng (Realtime)
  Stream<List<Invoice>> getInvoicesByContract(String contractId) {
    if (_currentUserId == null) return const Stream.empty();
    
    return _invoicesCollection
        .where('contractId', isEqualTo: contractId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // Lấy tất cả hóa đơn (cho thống kê)
  Stream<List<Invoice>> getAllInvoices() {
    if (_currentUserId == null) return const Stream.empty();
    
    return _invoicesCollection
        .where('ownerId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // Tạo hóa đơn mới
  Future<void> createInvoice(Invoice invoice) async {
    if (_currentUserId == null) throw Exception('Vui lòng đăng nhập!');

    // Kiểm tra xem tháng/năm này đã có hóa đơn cho hợp đồng này chưa
    final checkSnapshot = await _invoicesCollection
        .where('contractId', isEqualTo: invoice.contractId)
        .where('month', isEqualTo: invoice.month)
        .where('year', isEqualTo: invoice.year)
        .get();

    if (checkSnapshot.docs.isNotEmpty) {
      throw Exception('Hóa đơn tháng ${invoice.month}/${invoice.year} đã tồn tại cho hợp đồng này!');
    }

    await _invoicesCollection.add(invoice.toMap());
  }

  // Đánh dấu đã thanh toán
  Future<void> markAsPaid(String invoiceId) async {
    await _invoicesCollection.doc(invoiceId).update({
      'isPaid': true,
      'paidDate': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Xóa hóa đơn
  Future<void> deleteInvoice(String invoiceId) async {
    await _invoicesCollection.doc(invoiceId).delete();
  }
}
