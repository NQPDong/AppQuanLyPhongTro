import 'dart:async';
import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';

class RoomProvider with ChangeNotifier {
  final RoomService _roomService = RoomService();
  StreamSubscription<List<RoomModel>>? _roomSubscription;

  List<RoomModel> _allRooms = []; // Chứa tất cả phòng tải về từ Firebase
  List<RoomModel> _filteredRooms = []; // Danh sách phòng sau khi đã lọc/tìm kiếm

  String _searchQuery = "";
  String _selectedStatus = "Tất cả"; // 'Tất cả', 'available', 'rented', 'maintenance'
  String _sortBy = 'roomNumber'; // 'roomNumber', 'priceAsc', 'priceDesc'
  double? _minPrice;
  double? _maxPrice;
  double? _minArea;
  double? _maxArea;

  List<RoomModel> get rooms => _filteredRooms;
  String get selectedStatus => _selectedStatus;
  String get sortBy => _sortBy;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  double? get minArea => _minArea;
  double? get maxArea => _maxArea;

  // Lắng nghe dữ liệu từ Firebase
  void loadRooms(String propertyId) {
    _roomSubscription?.cancel();
    _roomSubscription = _roomService.getRoomsByProperty(propertyId).listen((data) {
      _allRooms = data;
      _applyFilter();
    });
  }

  // Logic tìm kiếm
  void search(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  // Logic lọc theo trạng thái
  void setStatusFilter(String status) {
    _selectedStatus = status;
    _applyFilter();
  }

  // Logic sắp xếp
  void setSortBy(String sort) {
    _sortBy = sort;
    _applyFilter();
  }

  // Logic lọc nâng cao (giá, diện tích)
  void setAdvancedFilter({
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
  }) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _minArea = minArea;
    _maxArea = maxArea;
    _applyFilter();
  }

  // Xóa bộ lọc nâng cao
  void clearAdvancedFilter() {
    _minPrice = null;
    _maxPrice = null;
    _minArea = null;
    _maxArea = null;
    _applyFilter();
  }

  void _applyFilter() {
    // Bước 1: Lọc theo trạng thái và tìm kiếm
    _filteredRooms = _allRooms.where((room) {
      final matchesSearch = room.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == "Tất cả" || room.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    // Bước 2: Lọc nâng cao theo giá, diện tích
    _filteredRooms = RoomService.filterRooms(
      rooms: _filteredRooms,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minArea: _minArea,
      maxArea: _maxArea,
    );

    // Bước 3: Sắp xếp
    switch (_sortBy) {
      case 'priceAsc':
        _filteredRooms.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'priceDesc':
        _filteredRooms.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'roomNumber':
      default:
        _filteredRooms.sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
        break;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }
}
