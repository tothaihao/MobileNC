import 'package:flutter/material.dart';
import '../models/district_model.dart';
import '../services/district_service.dart';

class DistrictWardPicker extends StatefulWidget {
  final String? initialDistrict;
  final String? initialWard;
  final void Function(String district, String ward) onChanged;

  const DistrictWardPicker({
    Key? key,
    this.initialDistrict,
    this.initialWard,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<DistrictWardPicker> createState() => _DistrictWardPickerState();
}

class _DistrictWardPickerState extends State<DistrictWardPicker> {
  List<District> _districts = [];
  District? _selectedDistrict;
  Ward? _selectedWard;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    final districts = await DistrictService.loadDistricts();
    setState(() {
      _districts = districts;
      // Set initial values if provided
      if (widget.initialDistrict != null) {
        _selectedDistrict = _districts.firstWhere(
          (d) => d.name == widget.initialDistrict,
          orElse: () => _districts.first,
        );
        if (widget.initialWard != null && _selectedDistrict != null) {
          _selectedWard = _selectedDistrict!.wards.firstWhere(
            (w) => w.name == widget.initialWard,
            orElse: () => _selectedDistrict!.wards.first,
          );
        }
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<District>(
            value: _selectedDistrict,
            decoration: const InputDecoration(labelText: 'Quận/Huyện'),
            items: _districts
                .map((d) => DropdownMenuItem(
                      value: d,
                      child: Text(d.name),
                    ))
                .toList(),
            onChanged: (district) {
              setState(() {
                _selectedDistrict = district;
                _selectedWard = null;
              });
              if (district != null) {
                widget.onChanged(district.name, '');
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<Ward>(
            value: _selectedWard,
            decoration: const InputDecoration(labelText: 'Phường/Xã'),
            items: (_selectedDistrict?.wards ?? [])
                .map((w) => DropdownMenuItem(
                      value: w,
                      child: Text(w.name),
                    ))
                .toList(),
            onChanged: (ward) {
              setState(() {
                _selectedWard = ward;
              });
              if (_selectedDistrict != null && ward != null) {
                widget.onChanged(_selectedDistrict!.name, ward.name);
              }
            },
          ),
        ),
      ],
    );
  }
} 