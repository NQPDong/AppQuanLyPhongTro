import 'package:flutter/material.dart';
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

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final property = Property(
          id: isEditing
              ? widget.property!.id
              : DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          imageUrl: _imageUrlController.text.trim(),
          roomCount: widget.property?.roomCount ?? 0,
          ownerId: widget.ownerId,
          createdAt: widget.property?.createdAt ?? DateTime.now(),
        );

        if (isEditing) {
          await PropertyService().updateProperty(property);
        } else {
          await PropertyService().addProperty(property);
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

              // URL ảnh
              TextFormField(
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'URL ảnh (Tùy chọn)',
                  hintText: 'https://example.com/image.jpg',
                  prefixIcon: const Icon(Icons.image),
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
