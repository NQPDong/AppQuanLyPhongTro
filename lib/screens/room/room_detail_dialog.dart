import 'package:flutter/material.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';

/// Dialog hiển thị chi tiết phòng + chức năng đổi trạng thái
class RoomDetailDialog extends StatelessWidget {
  final Room room;

  const RoomDetailDialog({super.key, required this.room});

  String _getDefaultRoomImage(String status, String roomId) {
    final Map<String, List<String>> statusImages = {
      'available': [
        'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=500&q=80',
      ],
      'rented': [
        'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=500&q=80',
      ],
      'maintenance': [
        'https://images.unsplash.com/photo-1581094288338-2314dddb7ecc?auto=format&fit=crop&w=500&q=80',
      ],
    };

    final images = statusImages[status] ?? statusImages['available']!;
    final index = roomId.hashCode.abs() % images.length;
    return images[index];
  }

  @override
  Widget build(BuildContext context) {
    final roomImage = room.imageUrl.isNotEmpty
        ? room.imageUrl
        : _getDefaultRoomImage(room.status, room.id);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh phòng trọ tràn viền ở trên
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  roomImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.meeting_room, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
                // Nút đóng ở góc trên bên phải
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Số phòng + Badge trạng thái
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Phòng ${room.roomNumber}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    _buildStatusBadge(room.status),
                  ],
                ),

                const Divider(height: 24, thickness: 1),

                // Thông tin chi tiết
                _buildInfoRow(Icons.stairs_outlined, 'Tầng', '${room.floor}'),
                const SizedBox(height: 12),
                _buildInfoRow(
                    Icons.square_foot_outlined, 'Diện tích', '${room.area.toStringAsFixed(1)} m²'),
                const SizedBox(height: 12),
                _buildInfoRow(
                    Icons.monetization_on_outlined, 'Giá thuê', _formatPrice(room.price)),
                const SizedBox(height: 12),
                if (room.description.isNotEmpty) ...[
                  _buildInfoRow(Icons.description_outlined, 'Mô tả', room.description),
                  const SizedBox(height: 12),
                ],

                const Divider(height: 24, thickness: 1),

                // Đổi trạng thái
                const Text(
                  'Cập nhật trạng thái:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatusButton(
                        context, 'available', 'Trống', Colors.green, room),
                    const SizedBox(width: 8),
                    _buildStatusButton(
                        context, 'rented', 'Đã thuê', Colors.red, room),
                    const SizedBox(width: 8),
                    _buildStatusButton(
                        context, 'maintenance', 'Bảo trì', Colors.orange, room),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Expanded(
          child: Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'available':
        color = Colors.green;
        text = 'Còn trống';
        break;
      case 'rented':
        color = Colors.red;
        text = 'Đã thuê';
        break;
      case 'maintenance':
        color = Colors.orange;
        text = 'Bảo trì';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(127)),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, String status,
      String label, Color color, Room room) {
    final isSelected = room.status == status;
    return Expanded(
      child: OutlinedButton(
        onPressed: isSelected
            ? null
            : () async {
                try {
                  await RoomService().updateRoomStatus(room.id, status);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã chuyển sang "$label"'),
                        backgroundColor: color,
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
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: isSelected ? color : Colors.grey[300]!),
          backgroundColor: isSelected ? color.withAlpha(25) : null,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}tr/tháng';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}k/tháng';
    }
    return '${price.toStringAsFixed(0)}đ/tháng';
  }
}
