import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/invoice.dart';
import 'api_config.dart';

class InvoiceService {
  String? get _currentUserId => AuthService.currentUser?.uid;

  static final StreamController<List<Invoice>> _allInvoicesController = StreamController<List<Invoice>>.broadcast();
  static final Map<String, StreamController<List<Invoice>>> _contractControllers = {};

  StreamController<List<Invoice>> _getOrCreateContractController(String contractId) {
    if (!_contractControllers.containsKey(contractId)) {
      _contractControllers[contractId] = StreamController<List<Invoice>>.broadcast();
    }
    return _contractControllers[contractId]!;
  }

  // Lấy danh sách hóa đơn theo hợp đồng (Realtime)
  Stream<List<Invoice>> getInvoicesByContract(String contractId) {
    if (_currentUserId == null) return const Stream.empty();
    _fetchInvoicesByContract(contractId);
    return _getOrCreateContractController(contractId).stream;
  }

  // Lấy tất cả hóa đơn (cho thống kê)
  Stream<List<Invoice>> getAllInvoices() {
    if (_currentUserId == null) return const Stream.empty();
    _fetchAllInvoices();
    return _allInvoicesController.stream;
  }

  Future<void> _fetchInvoicesByContract(String contractId) async {
    try {
      final response = await ApiConfig.request(() => http.get(
        Uri.parse('${ApiConfig.baseUrl}/invoices?contractId=$contractId'),
      ));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final invoices = data.map((json) => Invoice.fromJson(json)).toList();
        _getOrCreateContractController(contractId).add(invoices);
      } else {
        _getOrCreateContractController(contractId).addError('Không thể tải hóa đơn theo hợp đồng (Mã lỗi: ${response.statusCode})');
      }
    } catch (e) {
      print('Lỗi tải hóa đơn theo hợp đồng: $e');
      _getOrCreateContractController(contractId).addError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _fetchAllInvoices() async {
    if (_currentUserId == null) return;
    try {
      final response = await ApiConfig.request(() => http.get(
        Uri.parse('${ApiConfig.baseUrl}/invoices?ownerId=$_currentUserId'),
      ));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final invoices = data.map((json) => Invoice.fromJson(json)).toList();
        _allInvoicesController.add(invoices);
      } else {
        _allInvoicesController.addError('Không thể tải danh sách hóa đơn (Mã lỗi: ${response.statusCode})');
      }
    } catch (e) {
      print('Lỗi tải tất cả hóa đơn: $e');
      _allInvoicesController.addError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Tạo hóa đơn mới
  Future<void> createInvoice(Invoice invoice) async {
    if (_currentUserId == null) throw Exception('Vui lòng đăng nhập!');

    try {
      final response = await ApiConfig.request(() => http.post(
        Uri.parse('${ApiConfig.baseUrl}/invoices'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ownerId': _currentUserId,
          'contractId': invoice.contractId,
          'roomId': invoice.roomId,
          'tenantId': invoice.tenantId,
          'month': invoice.month,
          'year': invoice.year,
          'oldElec': invoice.oldElec,
          'newElec': invoice.newElec,
          'elecPrice': invoice.elecPrice,
          'oldWater': invoice.oldWater,
          'newWater': invoice.newWater,
          'waterPrice': invoice.waterPrice,
          'serviceFee': invoice.serviceFee,
          'totalAmount': invoice.totalAmount,
        }),
      ));

      if (response.statusCode == 200) {
        await _fetchInvoicesByContract(invoice.contractId);
        await _fetchAllInvoices();
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Lỗi tạo hóa đơn mới.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Đánh dấu đã thanh toán
  Future<void> markAsPaid(String invoiceId) async {
    try {
      final response = await ApiConfig.request(() => http.put(
        Uri.parse('${ApiConfig.baseUrl}/invoices/$invoiceId/pay'),
      ));

      if (response.statusCode == 200) {
        final updatedInvoice = jsonDecode(response.body);
        final String contractId = updatedInvoice['contractId'];
        await _fetchInvoicesByContract(contractId);
        await _fetchAllInvoices();
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Lỗi thanh toán hóa đơn.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Xóa hóa đơn
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      final response = await ApiConfig.request(() => http.delete(
        Uri.parse('${ApiConfig.baseUrl}/invoices/$invoiceId'),
      ));

      if (response.statusCode == 200) {
        await _fetchAllInvoices();
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Lỗi xóa hóa đơn.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
