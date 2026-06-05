import 'package:flutter/material.dart';

class FilterChipsWidget extends StatefulWidget {
  final Function(String) onFilterChanged;

  const FilterChipsWidget({super.key, required this.onFilterChanged});

  @override
  State<FilterChipsWidget> createState() => _FilterChipsWidgetState();
}

class _FilterChipsWidgetState extends State<FilterChipsWidget> {
  // Danh sách các nhãn hiển thị
  final List<String> _filters = ["Tất cả", "available", "rented", "maintenance"];
  final List<String> _displayLabels = ["Tất cả", "Còn trống", "Đã thuê", "Bảo trì"];

  String _currentFilter = "Tất cả";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: List<Widget>.generate(_filters.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(_displayLabels[index]),
              selected: _currentFilter == _filters[index],
              onSelected: (bool selected) {
                setState(() {
                  _currentFilter = _filters[index];
                });
                widget.onFilterChanged(_currentFilter);
              },
              selectedColor: Colors.blue.withAlpha(51),
              labelStyle: TextStyle(color: _currentFilter == _filters[index] ? Colors.blue : Colors.black, fontWeight: _currentFilter == _filters[index] ? FontWeight.bold : FontWeight.normal),
            ),
          );
        }),
      ),
    );
  }
}
