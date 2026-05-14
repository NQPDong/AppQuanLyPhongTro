import 'package:flutter/material.dart';
import '../models/property.dart';
import '../models/room.dart';
import '../models/tenant.dart';
import '../services/property_service.dart';
import '../services/room_service.dart';
import '../services/tenant_service.dart';
import '../services/contract_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddContractScreen extends StatefulWidget {
  const AddContractScreen({super.key});

  @override
  State<AddContractScreen> createState() => _AddContractScreenState();
}

class _AddContractScreenState extends State<AddContractScreen> {
  int _currentStep = 0;
  final PropertyService _propertyService = PropertyService();
  final RoomService _roomService = RoomService();
  final TenantService _tenantService = TenantService();
  final ContractService _contractService = ContractService();

  String? _selectedPropertyId;
  String? _selectedRoomId;
  String? _selectedTenantId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  final _depositController = TextEditingController();

  List<Step> get _steps => [
        Step(
          title: const Text('Chọn phòng'),
          isActive: _currentStep >= 0,
          content: Column(
            children: [
              StreamBuilder<List<Property>>(
                stream: _propertyService.getProperties(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  return DropdownButtonFormField<String>(
                    value: _selectedPropertyId,
                    hint: const Text('Chọn cơ sở'),
                    items: snapshot.data!.map((p) {
                      return DropdownMenuItem(value: p.id, child: Text(p.name));
                    }).toList(),
                    onChanged: (id) => setState(() {
                      _selectedPropertyId = id;
                      _selectedRoomId = null;
                    }),
                  );
                },
              ),
              if (_selectedPropertyId != null) ...[
                const SizedBox(height: 16),
                StreamBuilder<List<Room>>(
                  stream: _roomService.getRoomsByProperty(_selectedPropertyId!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final availableRooms = snapshot.data!.where((r) => r.status == 'available').toList();
                    if (availableRooms.isEmpty) return const Text('Không có phòng trống');
                    return DropdownButtonFormField<String>(
                      value: _selectedRoomId,
                      hint: const Text('Chọn phòng trống'),
                      items: availableRooms.map((r) {
                        return DropdownMenuItem(value: r.id, child: Text('Phòng ${r.roomNumber} - ${r.price}đ'));
                      }).toList(),
                      onChanged: (id) => setState(() => _selectedRoomId = id),
                    );
                  },
                ),
              ]
            ],
          ),
        ),
        Step(
          title: const Text('Chọn khách thuê'),
          isActive: _currentStep >= 1,
          content: StreamBuilder<List<Tenant>>(
            stream: _tenantService.getTenants(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              return DropdownButtonFormField<String>(
                value: _selectedTenantId,
                hint: const Text('Chọn khách thuê'),
                items: snapshot.data!.map((t) {
                  return DropdownMenuItem(value: t.id, child: Text(t.fullName));
                }).toList(),
                onChanged: (id) => setState(() => _selectedTenantId = id),
              );
            },
          ),
        ),
        Step(
          title: const Text('Thông tin hợp đồng'),
          isActive: _currentStep >= 2,
          content: Column(
            children: [
              ListTile(
                title: Text('Ngày bắt đầu: ${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
              ListTile(
                title: Text('Ngày kết thúc: ${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _endDate = picked);
                },
              ),
              TextField(
                controller: _depositController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tiền cọc (VNĐ)', prefixIcon: Icon(Icons.money)),
              ),
            ],
          ),
        ),
      ];

  void _submit() async {
    if (_selectedRoomId == null || _selectedTenantId == null || _depositController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ thông tin')));
      return;
    }

    try {
      await _contractService.createContract(
        propertyId: _selectedPropertyId!,
        roomId: _selectedRoomId!,
        tenantId: _selectedTenantId!,
        startDate: _startDate,
        endDate: _endDate,
        depositAmount: double.parse(_depositController.text),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo hợp đồng thành công!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo hợp đồng mới')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < _steps.length - 1) {
            setState(() => _currentStep += 1);
          } else {
            _submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: _steps,
      ),
    );
  }
}
