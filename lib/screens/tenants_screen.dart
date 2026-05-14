import 'package:flutter/material.dart';
import '../models/tenant.dart';
import '../services/tenant_service.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  final TenantService _tenantService = TenantService();
  String _searchQuery = '';

  void _showTenantDialog({Tenant? tenant}) {
    final nameController = TextEditingController(text: tenant?.fullName);
    final phoneController = TextEditingController(text: tenant?.phone);
    final idCardController = TextEditingController(text: tenant?.idCard);
    final addressController = TextEditingController(text: tenant?.address);
    final notesController = TextEditingController(text: tenant?.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tenant == null ? 'Thêm khách thuê mới' : 'Sửa thông tin khách'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và tên *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Số điện thoại *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: idCardController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số CMND/CCCD *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Địa chỉ thường trú', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Ghi chú', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || phoneController.text.isEmpty || idCardController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ các trường bắt buộc!')));
                return;
              }
              
              try {
                if (tenant == null) {
                  await _tenantService.addTenant(
                    fullName: nameController.text,
                    phone: phoneController.text,
                    idCard: idCardController.text,
                    address: addressController.text,
                    notes: notesController.text,
                  );
                } else {
                  await _tenantService.updateTenant(
                    tenant.id,
                    fullName: nameController.text,
                    phone: phoneController.text,
                    idCard: idCardController.text,
                    address: addressController.text,
                    notes: notesController.text,
                  );
                }
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String tenantId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa khách thuê?'),
        content: const Text('Bạn có chắc chắn muốn xóa khách thuê này khỏi hệ thống không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              await _tenantService.deleteTenant(tenantId);
              if (context.mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight + 20),
        child: Column(
          children: [
            // Search Bar
            Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc SĐT...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<Tenant>>(
              stream: _tenantService.getTenants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));

                var tenants = snapshot.data ?? [];
                
                // Lọc Client-side
                if (_searchQuery.isNotEmpty) {
                  tenants = tenants.where((t) => 
                    t.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                    t.phone.contains(_searchQuery)
                  ).toList();
                }

                if (tenants.isEmpty) return const Center(child: Text('Không tìm thấy khách thuê nào.'));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tenants.length,
                  itemBuilder: (context, index) {
                    final tenant = tenants[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.black.withOpacity(0.05)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFEEF2FF),
                          foregroundColor: const Color(0xFF6366F1),
                          child: Text(tenant.fullName.isNotEmpty ? tenant.fullName[0].toUpperCase() : 'K'),
                        ),
                        title: Text('${tenant.code.isNotEmpty ? tenant.code + ' - ' : ''}${tenant.fullName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('SĐT: ${tenant.phone}'),
                            Text('CCCD: ${tenant.idCard}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _showPropertyDialog(tenant);
                            if (value == 'delete') _confirmDelete(tenant.id);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Sửa')])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))])),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTenantDialog(),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
    );
  }

  void _showPropertyDialog(Tenant tenant) {
    _showTenantDialog(tenant: tenant);
  }
}
