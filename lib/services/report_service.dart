import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class DashboardStats {
  final List<double> monthlyRevenue;
  final int rentedCount;
  final int availableCount;

  DashboardStats({
    required this.monthlyRevenue,
    required this.rentedCount,
    required this.availableCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    var rawRevenue = json['monthlyRevenue'] as List<dynamic>? ?? [];
    List<double> revenue = rawRevenue.map((v) => (v as num).toDouble()).toList();
    return DashboardStats(
      monthlyRevenue: revenue,
      rentedCount: json['rentedCount'] ?? 0,
      availableCount: json['availableCount'] ?? 0,
    );
  }
}

class ReportService {
  Future<DashboardStats> getStatistics(String ownerId, int year) async {
    try {
      final response = await ApiConfig.request(() => http.get(
        Uri.parse('${ApiConfig.baseUrl}/reports/statistics?ownerId=$ownerId&year=$year'),
      ));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return DashboardStats.fromJson(data);
      } else {
        throw Exception('Không thể tải dữ liệu thống kê báo cáo.');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
