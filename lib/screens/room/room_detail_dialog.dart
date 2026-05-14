import 'package:flutter/material.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';

/// Dialog hiển thị chi tiết phòng + chức năng đổi trạng thái
class RoomDetailDialog extends StatelessWidget {
  final Room room;

  const RoomDetailDialog({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.meeting_room,
                      color: Colors.blueAccent, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phòng ${room.roomNumber}',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(room.status),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const Divider(height: 24),

            // Thông tin chi tiết
            _buildInfoRow(Icons.stairs, 'Tầng', '${room.floor}'),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.square_foot, 'Diện tích', '${room.area.toStringAsFixed(1)} m²'),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.attach_money, 'Giá thuê', _formatPrice(room.price)),
            const SizedBox(height: 12),
            if (room.description.isNotEmpty) ...[
              _buildInfoRow(Icons.description, 'Mô tả', room.description),
              const SizedBox(height: 12),
            ],

            const Divider(height: 24),

            // Đổi trạng thái
            const Text(
              'Đổi trạng thái:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
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
