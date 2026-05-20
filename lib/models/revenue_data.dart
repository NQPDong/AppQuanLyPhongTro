class RevenueData {
  final String month;
  final double revenue;

  RevenueData({required this.month, required this.revenue});

  // Constructor để lấy dữ liệu mẫu hoặc từ Firebase sau này
  static List<RevenueData> getYearlyRevenue(int year) {
    return [
      RevenueData(month: 'T01', revenue: 50.5),
      RevenueData(month: 'T02', revenue: 45.0),
      RevenueData(month: 'T03', revenue: 60.2),
      // ... thêm dữ liệu
    ];
  }
}
