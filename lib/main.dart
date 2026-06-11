import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/property_provider.dart';
import 'providers/room_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/property/property_screen.dart';
import 'screens/tenants_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';
import 'services/auth_service.dart';
import 'services/room_service.dart';
import 'services/contract_service.dart';
import 'services/invoice_service.dart';
import 'models/room.dart';
import 'models/contract.dart';
import 'models/invoice.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Thử auto-login từ SharedPreferences
  await AuthService.tryAutoLogin();
  runApp(const QuanLyPhongTroApp());
}

class QuanLyPhongTroApp extends StatelessWidget {
  const QuanLyPhongTroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
      ],
      child: MaterialApp(
        title: 'Quản Lý Phòng Trọ',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            primary: const Color(0xFF6366F1),
            secondary: const Color(0xFF10B981),
            surface: const Color(0xFFF8FAFC),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            titleTextStyle: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white,
          ),
        ),
        // Nếu đã auto-login thành công → vào MainLayout, ngược lại → Login
        initialRoute: AuthService.currentUser != null ? '/' : '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/': (context) => const MainLayout(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Khởi tạo PropertyProvider với userId từ AuthService
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = AuthService.currentUser;
      if (user != null) {
        context.read<PropertyProvider>().init(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(),
      const PropertyListScreen(),
      const TenantsScreen(),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 2,
        title: Text(_selectedIndex == 0 
            ? 'Tổng quan' 
            : (_selectedIndex == 1 
                ? 'Danh sách cơ sở' 
                : (_selectedIndex == 2 
                    ? 'Khách thuê' 
                    : (_selectedIndex == 3 ? 'Báo cáo' : 'Hồ sơ cá nhân')))),
        actions: [
          StreamBuilder<List<Room>>(
            stream: RoomService().getAllRooms(),
            builder: (context, roomSnapshot) {
              return StreamBuilder<List<Contract>>(
                stream: ContractService().getContracts(),
                builder: (context, contractSnapshot) {
                  return StreamBuilder<List<Invoice>>(
                    stream: InvoiceService().getAllInvoices(),
                    builder: (context, invoiceSnapshot) {
                      final rooms = roomSnapshot.data ?? [];
                      final contracts = contractSnapshot.data ?? [];
                      final invoices = invoiceSnapshot.data ?? [];
                      
                      final alerts = _generateNotifications(invoices, contracts, rooms);
                      final hasNotifications = alerts.isNotEmpty;

                      return Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E293B)),
                              position: PopupMenuPosition.under,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              itemBuilder: (context) {
                                if (alerts.isEmpty) {
                                  return [
                                    const PopupMenuItem(
                                      enabled: false,
                                      child: SizedBox(
                                        width: 280,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.notifications_off_outlined, color: Colors.grey, size: 40),
                                            SizedBox(height: 8),
                                            Text(
                                              'Không có thông báo mới!',
                                              style: TextStyle(color: Colors.grey, fontSize: 14),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ];
                                }

                                return [
                                  PopupMenuItem(
                                    enabled: false,
                                    child: SizedBox(
                                      width: 280,
                                      height: 300,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.notifications_active_rounded, color: Color(0xFF6366F1), size: 20),
                                              const SizedBox(width: 8),
                                              Text('Cảnh báo & Nhắc nhở (${alerts.length})', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 15)),
                                            ],
                                          ),
                                          const Divider(height: 16),
                                          Expanded(
                                            child: ListView.separated(
                                              itemCount: alerts.length,
                                              separatorBuilder: (context, index) => const Divider(height: 8),
                                              itemBuilder: (context, index) {
                                                final alert = alerts[index];
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Icon(alert.icon, color: alert.color, size: 18),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              alert.title,
                                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B)),
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              alert.content,
                                                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ];
                              },
                            ),
                            if (hasNotifications)
                              Positioned(
                                right: 10,
                                top: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 8,
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 75,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              selectedIcon: Icon(Icons.grid_view_rounded, color: Color(0xFF6366F1)),
              label: 'Tổng quan',
            ),
            NavigationDestination(
              icon: Icon(Icons.apartment_rounded),
              selectedIcon: Icon(Icons.apartment_rounded, color: Color(0xFF6366F1)),
              label: 'Nhà trọ',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_alt_rounded),
              selectedIcon: Icon(Icons.people_alt_rounded, color: Color(0xFF6366F1)),
              label: 'Khách thuê',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: Color(0xFF6366F1)),
              label: 'Thống kê',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_pin_rounded),
              selectedIcon: Icon(Icons.person_pin_rounded, color: Color(0xFF6366F1)),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }

  List<AppNotification> _generateNotifications(
    List<Invoice> invoices,
    List<Contract> contracts,
    List<Room> rooms,
  ) {
    final List<AppNotification> alerts = [];
    final roomMap = {for (var r in rooms) r.id: r.roomNumber};

    // 1. Nhắc thu tiền phòng (isPaid == false)
    for (var inv in invoices) {
      if (!inv.isPaid) {
        final roomNum = roomMap[inv.roomId] ?? 'N/A';
        alerts.add(AppNotification(
          title: 'Nhắc thu tiền phòng',
          content: 'Phòng $roomNum chưa thanh toán hóa đơn Tháng ${inv.month}/${inv.year}.',
          icon: Icons.monetization_on_rounded,
          color: const Color(0xFFEF4444), // Đỏ
          date: inv.createdAt,
        ));
      }
    }

    // 2. Nhắc hợp đồng sắp hết hạn (còn dưới 30 ngày)
    final now = DateTime.now();
    for (var ctr in contracts) {
      if (ctr.status == 'active') {
        final daysLeft = ctr.endDate.difference(now).inDays;
        if (daysLeft >= 0 && daysLeft <= 30) {
          final roomNum = roomMap[ctr.roomId] ?? 'N/A';
          alerts.add(AppNotification(
            title: 'Hợp đồng sắp hết hạn',
            content: 'Hợp đồng Phòng $roomNum sẽ hết hạn sau $daysLeft ngày (ngày ${ctr.endDate.day}/${ctr.endDate.month}/${ctr.endDate.year}).',
            icon: Icons.assignment_late_rounded,
            color: const Color(0xFFF59E0B), // Cam
            date: ctr.createdAt,
          ));
        }
      }
    }

    // Sắp xếp thông báo mới nhất lên trên
    alerts.sort((a, b) => b.date.compareTo(a.date));
    return alerts;
  }
}

class AppNotification {
  final String title;
  final String content;
  final IconData icon;
  final Color color;
  final DateTime date;

  AppNotification({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
    required this.date,
  });
}
