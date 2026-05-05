import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../models/room_model.dart';
import '../../services/room_service.dart';
import '../../services/property_service.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/filter_chips_widget.dart';
import 'add_room_dialog.dart';
import 'room_detail_dialog.dart';

/// MÀN HÌNH DANH SÁCH PHÒNG TRỌ — Grid 2 cột
class RoomGridScreen extends StatefulWidget {
  final PropertyModel property;
  const RoomGridScreen({super.key, required this.property});

  @override
  State<RoomGridScreen> createState() => _RoomGridScreenState();
}

class _RoomGridScreenState extends State<RoomGridScreen> {
  // State cho lọc / tìm kiếm / sắp xếp
  String _searchText = '';
  String _statusFilter = 'Tất cả';
  String _sortBy = 'roomNumber'; // 'roomNumber', 'priceAsc', 'priceDesc'

  // State cho bộ lọc nâng cao
  double? _minPrice;
  double? _maxPrice;
  double? _minArea;
  double? _maxArea;

  /// Áp dụng tất cả bộ lọc + sắp xếp lên danh sách phòng gốc
  List<RoomModel> _applyFilters(List<RoomModel> allRooms) {
    // Bước 1: Tìm kiếm theo số phòng
    var rooms = allRooms.where((room) {
      final matchesSearch =
          _searchText.isEmpty || room.roomNumber.toLowerCase().contains(_searchText.toLowerCase());
      final matchesStatus =
          _statusFilter == 'Tất cả' || room.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    // Bước 2: Lọc nâng cao (giá, diện tích)
    rooms = RoomService.filterRooms(
      rooms: rooms,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minArea: _minArea,
      maxArea: _maxArea,
    );

    // Bước 3: Sắp xếp
    switch (_sortBy) {
      case 'priceAsc':
        rooms.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'priceDesc':
        rooms.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'roomNumber':
      default:
        rooms.sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
        break;
    }

    return rooms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phòng tại ${widget.property.name}"),
        actions: [
          // Nút sắp xếp
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sắp xếp',
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              _buildSortMenuItem('roomNumber', 'Số phòng (A-Z)', Icons.sort_by_alpha),
              _buildSortMenuItem('priceAsc', 'Giá tăng dần', Icons.arrow_upward),
              _buildSortMenuItem('priceDesc', 'Giá giảm dần', Icons.arrow_downward),
            ],
          ),
          // Nút bộ lọc nâng cao
          IconButton(
            icon: Badge(
              isLabelVisible: _minPrice != null ||
                  _maxPrice != null ||
                  _minArea != null ||
                  _maxArea != null,
              child: const Icon(Icons.filter_alt_outlined),
            ),
            tooltip: 'Bộ lọc nâng cao',
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Thanh tìm kiếm
          SearchBarWidget(
            hintText: "Tìm số phòng...",
            onChanged: (value) {
              setState(() => _searchText = value);
            },
          ),

          // 2. Filter Chips (lọc nhanh trạng thái)
          FilterChipsWidget(
            onFilterChanged: (status) {
              setState(() => _statusFilter = status);
            },
          ),
          const SizedBox(height: 4),

          // 3. Danh sách phòng dạng Grid (dữ liệu realtime từ Firebase)
          Expanded(
            child: StreamBuilder<List<RoomModel>>(
              stream:
                  RoomService().getRoomsByProperty(widget.property.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Lỗi tải dữ liệu: ${snapshot.error}"));
                }

                final allRooms = snapshot.data ?? [];

                if (allRooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.meeting_room_outlined,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "Chưa có phòng nào.\nHãy nhấn nút + để thêm phòng.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                              height: 1.5),
                        ),
                      ],
                    ),
                  );
                }

                final filteredRooms = _applyFilters(allRooms);

                if (filteredRooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          "Không có phòng nào phù hợp",
                          style: TextStyle(
                              fontSize: 15, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredRooms.length,
                  itemBuilder: (context, index) {
                    return _buildRoomCard(filteredRooms[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                AddRoomDialog(propertyId: widget.property.id),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // =================== ROOM CARD ===================
  Widget _buildRoomCard(RoomModel room) {
    final statusInfo = _getStatusInfo(room.status);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Hiển thị dialog chi tiết phòng
          showDialog(
            context: context,
            builder: (context) => RoomDetailDialog(room: room),
          );
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: số phòng + menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Phòng ${room.roomNumber}",
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Menu 3 chấm: sửa / xóa
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          icon: const Icon(Icons.more_vert,
                              size: 18, color: Colors.grey),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editRoom(room);
                            } else if (value == 'delete') {
                              _confirmDeleteRoom(room);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit,
                                      color: Colors.blue, size: 18),
                                  SizedBox(width: 8),
                                  Text('Sửa phòng'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      color: Colors.red, size: 18),
                                  SizedBox(width: 8),
                                  Text('Xóa phòng',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Icon phòng ở giữa
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: statusInfo['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.meeting_room,
                          size: 32, color: statusInfo['color']),
                    ),
                  ),

                  const Spacer(),

                  // Giá
                  Text(
                    _formatPrice(room.price),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Diện tích
                  Text(
                    '${room.area.toStringAsFixed(0)} m²  •  Tầng ${room.floor}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),

                  // Status badge
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusInfo['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: statusInfo['color'].withOpacity(0.3)),
                    ),
                    child: Text(
                      statusInfo['text'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: statusInfo['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================== SORT MENU ITEM ===================
  PopupMenuItem<String> _buildSortMenuItem(
      String value, String label, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: _sortBy == value ? Colors.blueAccent : Colors.grey),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: _sortBy == value ? Colors.blueAccent : null,
              fontWeight:
                  _sortBy == value ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (_sortBy == value) ...[
            const Spacer(),
            const Icon(Icons.check, size: 18, color: Colors.blueAccent),
          ],
        ],
      ),
    );
  }

  // =================== FILTER BOTTOM SHEET ===================
  void _showFilterBottomSheet(BuildContext context) {
    // Controller tạm cho bottom sheet
    final minPriceCtrl =
        TextEditingController(text: _minPrice?.toStringAsFixed(0) ?? '');
    final maxPriceCtrl =
        TextEditingController(text: _maxPrice?.toStringAsFixed(0) ?? '');
    final minAreaCtrl =
        TextEditingController(text: _minArea?.toStringAsFixed(0) ?? '');
    final maxAreaCtrl =
        TextEditingController(text: _maxArea?.toStringAsFixed(0) ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tiêu đề
              const Row(
                children: [
                  Icon(Icons.filter_alt, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text('Bộ lọc nâng cao',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // Lọc theo giá
              const Text('Giá thuê (VNĐ/tháng)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Từ',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('—'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: maxPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Đến',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lọc theo diện tích
              const Text('Diện tích (m²)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minAreaCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Từ',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('—'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: maxAreaCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Đến',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nút hành động
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = null;
                          _maxPrice = null;
                          _minArea = null;
                          _maxArea = null;
                        });
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Xóa bộ lọc'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = double.tryParse(minPriceCtrl.text);
                          _maxPrice = double.tryParse(maxPriceCtrl.text);
                          _minArea = double.tryParse(minAreaCtrl.text);
                          _maxArea = double.tryParse(maxAreaCtrl.text);
                        });
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Áp dụng'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // =================== EDIT / DELETE ===================
  void _editRoom(RoomModel room) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddRoomDialog(
        propertyId: widget.property.id,
        room: room,
      ),
    );
  }

  void _confirmDeleteRoom(RoomModel room) {
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
          'Bạn có chắc muốn xóa phòng "${room.roomNumber}"?\n\nHành động này không thể hoàn tác.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              try {
                await RoomService().deleteRoom(room.id);
                await PropertyService().updateRoomCount(room.propertyId, -1);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa phòng!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // =================== UTILS ===================
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'available':
        return {'color': Colors.green, 'text': 'Còn trống'};
      case 'rented':
        return {'color': Colors.red, 'text': 'Đã thuê'};
      case 'maintenance':
        return {'color': Colors.orange, 'text': 'Bảo trì'};
      default:
        return {'color': Colors.grey, 'text': status};
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}tr/th';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}k/th';
    }
    return '${price.toStringAsFixed(0)}đ/th';
  }
}
