import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contract.dart';
import '../services/contract_service.dart';
import 'add_contract_screen.dart';
import 'contract_details_screen.dart';
import 'invoices_screen.dart';

class ContractsScreen extends StatefulWidget {
  const ContractsScreen({super.key});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  final ContractService _contractService = ContractService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Danh sách Hợp đồng'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: StreamBuilder<List<Contract>>(
        stream: _contractService.getContracts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final contracts = snapshot.data ?? [];

          if (contracts.isEmpty) {
            return const Center(
              child: Text('Chưa có hợp đồng nào.', style: TextStyle(color: Color(0xFF64748B))),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final contract = contracts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.black.withOpacity(0.05)),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContractDetailsScreen(contract: contract)),
                    );
                  },
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: contract.status == 'active' ? const Color(0xFFEEF2FF) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      color: contract.status == 'active' ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
                    ),
                  ),
                  title: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('rooms').doc(contract.roomId).get(),
                    builder: (context, roomSnap) {
                      String roomName = 'Đang tải...';
                      if (roomSnap.hasData && roomSnap.data!.exists) {
                        roomName = 'Phòng ${roomSnap.data!['roomNumber']}';
                      }
                      String contractTitle = contract.code.isNotEmpty ? 'Hợp đồng ${contract.code}' : 'Hợp đồng';
                      return Text(
                        '$contractTitle - $roomName',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      );
                    },
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Tiền cọc: ${(contract.depositAmount / 1000000).toStringAsFixed(1)} Tr'),
                      Text('Trạng thái: ${contract.status == 'active' ? 'Đang thuê' : 'Đã thanh lý'}', 
                        style: TextStyle(
                          color: contract.status == 'active' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  ),
                  trailing: contract.status == 'active' 
                    ? IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                        tooltip: 'Thanh lý hợp đồng',
                        onPressed: () {
                          _contractService.terminateContract(contract.id, contract.roomId);
                        },
                      )
                    : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddContractScreen()),
          );
        },
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
