import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';
import '../../services/property_service.dart';

class AddRoomDialog extends StatefulWidget {
  final String propertyId;
  final Room? room; // null = thêm mới, có giá trị = sửa

  const AddRoomDialog({
    super.key,
    required this.propertyId,
    this.room,
  });

  @override
  State<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roomNumberController;
  late TextEditingController _floorController;
  late TextEditingController _priceController;
  late TextEditingController _areaController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  bool get isEditing => widget.room != null;

  @override
  void initState() {
    super.initState();
    _roomNumberController =
        TextEditingController(text: widget.room?.roomNumber ?? '');
    _floorController =
        TextEditingController(text: widget.room?.floor.toString() ?? '1');
    _priceController = TextEditingController(
        text: widget.room != null ? widget.room!.price.toStringAsFixed(0) : '');
    _areaController = TextEditingController(
        text: widget.room != null ? widget.room!.area.toStringAsFixed(0) : '');
    _descriptionController =
        TextEditingController(text: widget.room?.description ?? '');
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _floorController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final room = Room(
          id: isEditing
              ? widget.room!.id
              : DateTime.now().millisecondsSinceEpoch.toString(),
          propertyId: widget.propertyId,
          ownerId: FirebaseAuth.instance.currentUser?.uid ?? '',
          roomNumber: _roomNumberController.text.trim(),
          floor: int.tryParse(_floorController.text) ?? 1,
          area: double.tryParse(_areaController.text) ?? 0,
          price: double.tryParse(_priceController.text) ?? 0,
          status: isEditing ? widget.room!.status : 'available',
          description: _descriptionController.text.trim(),
          createdAt: isEditing ? widget.room!.createdAt : DateTime.now(),
        );

        if (isEditing) {
          await RoomService().updateRoom(room);
        } else {
          await RoomService().addRoom(room);
          await PropertyService().updateRoomCount(widget.propertyId, 1);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  isEditing ? 'Cập nhật phòng thành công!' : 'Thêm phòng thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit : Icons.add_circle_outline,
            color: Colors.blueAccent,
          ),
          const SizedBox(width: 8),
          Text(isEditing ? 'Sửa Phòng' : 'Thêm Phòng Mới'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Số phòng
              TextFormField(
                controller: _roomNumberController,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Số phòng',
                  hintText: 'VD: 101, 202, A1...',
                  prefixIcon: const Icon(Icons.meeting_room),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Bắt buộc nhập số phòng' : null,
              ),
              const SizedBox(height: 12),

              // Tầng + Diện tích
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _floorController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Tầng',
                        prefixIcon: const Icon(Icons.stairs),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _areaController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Diện tích (m²)',
                        prefixIcon: const Icon(Icons.square_foot),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Giá phòng
              TextFormField(
                controller: _priceController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Giá phòng (VNĐ/Tháng)',
                  hintText: 'VD: 3000000',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Bắt buộc nhập giá' : null,
              ),
              const SizedBox(height: 12),

              // Mô tả
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Mô tả thêm (Tùy chọn)',
                  hintText: 'VD: Có ban công, máy lạnh...',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        FilledButton.icon(
          onPressed: _isLoading ? null : _submit,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Icon(isEditing ? Icons.save : Icons.add),
          label: Text(isEditing ? 'Lưu' : 'Thêm'),
        ),
      ],
    );
  }
}
