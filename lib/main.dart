import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/property_provider.dart';
import 'providers/room_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/property/property_screen.dart';
import 'screens/tenants_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        // Cấu hình Routes
        initialRoute: '/login', // Mặc định vào Login trước
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
    // Khởi tạo PropertyProvider với userId từ Firebase Auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<PropertyProvider>().init(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(),
      const PropertyListScreen(), // Màn hình Cơ sở/Phòng trọ của Thành viên 2
      const TenantsScreen(),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
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
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.notifications_none, color: Color(0xFF1E293B)),
              position: PopupMenuPosition.under,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  enabled: false,
                  child: SizedBox(
                    width: 280,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notifications_active_rounded, color: Color(0xFF6366F1), size: 20),
                            SizedBox(width: 8),
                            Text('Thông báo', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16)),
                          ],
                        ),
                        Divider(height: 16),
                        Text(
                          'Chào mừng bạn đến với hệ thống quản lý nhà trọ!', 
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
}
