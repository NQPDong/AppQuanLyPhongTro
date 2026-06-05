import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/property.dart';
import '../../providers/property_provider.dart';
import '../../services/property_service.dart';
import 'add_property_dialog.dart';
import '../room/room_screen.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  String get ownerId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    // Khởi tạo Provider: lắng nghe dữ liệu realtime từ Firebase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ownerId.isNotEmpty) {
        context.read<PropertyProvider>().init(ownerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cơ sở của tôi"),
        elevation: 0,
      ),
      // SỬ DỤNG CONSUMER ĐỂ LẤY DỮ LIỆU TỪ PROVIDER
      body: Consumer<PropertyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
                child: Text("Lỗi tải dữ liệu: ${provider.error}"));
          }
          if (provider.properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work_outlined,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Bạn chưa có nhà trọ nào.\nHãy nhấn nút + để thêm mới.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey[500], height: 1.5),
                  ),
                ],
              ),
            );
          }

          final properties = provider.properties;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return _buildPropertyCard(context, property, ownerId);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AddPropertyDialog(ownerId: ownerId),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Thêm cơ sở"),
      ),
    );
  }

  final List<String> _defaultPropertyImages = const [
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1582407947304-fd86f028f716?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=800&q=80',
  ];

  String _getDefaultPropertyImage(String propertyId) {
    final index = propertyId.hashCode.abs() % _defaultPropertyImages.length;
    return _defaultPropertyImages[index];
  }

  Widget _buildPropertyCard(
      BuildContext context, Property property, String ownerId) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RoomGridScreen(property: property)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh cơ sở
            _buildPropertyImage(property),

            // Thông tin cơ sở
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Thông tin bên trái
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                property.address,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.meeting_room_outlined,
                                size: 16, color: Color(0xFF6366F1)),
                            const SizedBox(width: 4),
                            Text(
                              '${property.totalRooms} phòng',
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Menu 3 chấm
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editProperty(context, property, ownerId);
                      } else if (value == 'delete') {
                        _confirmDeleteProperty(context, property);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text('Sửa cơ sở'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Xóa cơ sở',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyImage(Property property) {
    final imageUrl = property.imageUrl.isNotEmpty
        ? property.imageUrl
        : _getDefaultPropertyImage(property.id);

    return SizedBox(
      height: 170,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 170,
            color: Colors.grey[100],
            child: Center(
              child: Icon(Icons.home_work_outlined, size: 50, color: Colors.grey[400]),
            ),
          );
        },
      ),
    );
  }

  void _editProperty(
      BuildContext context, Property property, String ownerId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddPropertyDialog(
        ownerId: ownerId,
        property: property,
      ),
    );
  }

  void _confirmDeleteProperty(BuildContext context, Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Text(
          'Bạn có chắc muốn xóa cơ sở "${property.name}"?\n\nHành động này không thể hoàn tác.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await PropertyService().deleteProperty(property.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa cơ sở!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Lỗi: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
