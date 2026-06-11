import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';

class AddPropertyDialog extends StatefulWidget {
  final String ownerId;
  final Property? property; // null = thêm mới, có giá trị = sửa

  const AddPropertyDialog({
    super.key,
    required this.ownerId,
    this.property,
  });

  @override
  State<AddPropertyDialog> createState() => _AddPropertyDialogState();
}

class _AddPropertyDialogState extends State<AddPropertyDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _imageUrlController;
  bool _isLoading = false;

  bool get isEditing => widget.property != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.property?.name ?? '');
    _addressController =
        TextEditingController(text: widget.property?.address ?? '');
    _imageUrlController =
        TextEditingController(text: widget.property?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _imageUrlController.text = 'data:image/png;base64,$base64String';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chọn ảnh: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildPreviewImage() {
    final imageUrl = _imageUrlController.text;
    final double size = 70;
    
    if (imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.apartment_rounded, color: const Color(0xFF94A3B8), size: size * 0.4),
      );
    }

    if (imageUrl.startsWith('data:image') || imageUrl.contains('base64,')) {
      try {
        final base64Content = imageUrl.split(',').last;
        final decodedBytes = base64Decode(base64Content);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            decodedBytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: size,
              height: size,
              color: const Color(0xFFF1F5F9),
              child: Icon(Icons.broken_image_rounded, color: Colors.red.shade300, size: size * 0.4),
            ),
          ),
        );
      } catch (e) {
        return Container(
          width: size,
          height: size,
          color: const Color(0xFFF1F5F9),
          child: Icon(Icons.broken_image_rounded, color: Colors.red.shade300, size: size * 0.4),
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: const Color(0xFFF1F5F9),
          child: Icon(Icons.broken_image_rounded, color: Colors.red.shade300, size: size * 0.4),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (isEditing) {
          await PropertyService().updateProperty(
            widget.property!.id,
            _nameController.text.trim(),
            _addressController.text.trim(),
            _imageUrlController.text.trim(),
          );
        } else {
          await PropertyService().addProperty(
            _nameController.text.trim(),
            _addressController.text.trim(),
            _imageUrlController.text.trim(),
          );
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  isEditing ? 'Cập nhật cơ sở thành công!' : 'Thêm cơ sở thành công!'),
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
            isEditing ? Icons.edit : Icons.add_home_work,
            color: Colors.blueAccent,
          ),
          const SizedBox(width: 8),
          Text(isEditing ? 'Sửa Cơ Sở' : 'Thêm Cơ Sở Mới'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tên cơ sở
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Tên cơ sở',
                  hintText: 'VD: Nhà trọ Hạnh Phúc',
                  prefixIcon: const Icon(Icons.home),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Vui lòng nhập tên cơ sở' : null,
              ),
              const SizedBox(height: 16),

              // Địa chỉ
              TextFormField(
                controller: _addressController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ',
                  hintText: 'VD: 123 Nguyễn Văn Cừ, Q.5',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Vui lòng nhập địa chỉ' : null,
              ),
              const SizedBox(height: 16),

              // Nút tải ảnh
              Row(
                children: [
                  _buildPreviewImage(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library_rounded, size: 18),
                      label: const Text('Chọn ảnh từ máy', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // URL ảnh
              TextFormField(
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onChanged: (val) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Hoặc dán URL ảnh vào đây',
                  hintText: 'https://example.com/image.jpg',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
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
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(isEditing ? Icons.save : Icons.add),
          label: Text(isEditing ? 'Lưu' : 'Thêm'),
        ),
      ],
    );
  }
}
