import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiConfig {
  static const Duration timeout = Duration(seconds: 10);

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5276/api';
    }
    // IP của máy tính trong mạng Wi-Fi cục bộ (Được cấu hình tự động từ ipconfig)
    // const String pcIp = '192.168.2.6';
    const String pcIp = '10.199.105.118';
    // Đặt thành true nếu muốn chạy trên THIẾT BỊ THẬT cùng mạng Wi-Fi
    // Đặt thành false nếu muốn chạy trên MÁY ẢO Android (Emulator)
    const bool useRealDevice = true;

    try {
      if (Platform.isAndroid) {
        return useRealDevice ? 'http://$pcIp:5276/api' : 'http://10.0.2.2:5276/api';
      }
    } catch (_) {
      // Bọc try-catch phòng trường hợp môi trường web/khác ném lỗi khi truy cập Platform
    }
    return useRealDevice ? 'http://$pcIp:5276/api' : 'http://localhost:5276/api';
  }

  // Wrapper gọi HTTP và bắt lỗi kết nối/timeout
  static Future<http.Response> request(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(timeout);
    } on TimeoutException {
      throw Exception('Kết nối đến máy chủ bị quá giờ (Timeout). Vui lòng kiểm tra lại server.');
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('SocketException') || errStr.contains('Connection refused') || errStr.contains('Failed host lookup') || errStr.contains('Connection failed') || errStr.contains('ClientException')) {
        throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng hoặc địa chỉ IP server.');
      }
      throw Exception('Lỗi kết nối hệ thống: $e');
    }
  }

  // Định dạng tiền tệ VND (Ví dụ: 1.445.000VND)
  static String formatVND(num amount) {
    int val = amount.round();
    String str = val.abs().toString();
    String result = '';
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = '.$result';
        count = 0;
      }
    }

    if (val < 0) {
      result = '-$result';
    }

    return '${result}VND';
  }
}
