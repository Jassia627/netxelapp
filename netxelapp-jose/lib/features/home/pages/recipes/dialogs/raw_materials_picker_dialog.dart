// ignore_for_file: unused_element, library_private_types_in_public_api, avoid_print

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:netxelapp/features/home/Entities/used_raw_material.dart';
import 'package:netxelapp/features/home/pages/recipes/services/raw_material_service.dart';

class RawMaterialPickerDialog extends StatefulWidget {
  final List<UsedRawMaterial> selectedRawMaterials;
  final Function(List<UsedRawMaterial>) onRawMaterialsSelected;

  const RawMaterialPickerDialog({
    super.key,
    required this.selectedRawMaterials,
    required this.onRawMaterialsSelected,
  });

  @override
  _RawMaterialPickerDialogState createState() =>
      _RawMaterialPickerDialogState();
}

class _RawMaterialPickerDialogState extends State<RawMaterialPickerDialog> {
  late List<UsedRawMaterial> _selectedRawMaterials;
  List<Map<String, dynamic>> _availableRawMaterials = [];
  final RawMaterialRepository rawMaterialRepository = RawMaterialRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRawMaterials = widget.selectedRawMaterials;
    _fetchAvailableRawMaterials();
  }

  Future<void> _fetchAvailableRawMaterials() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rawMaterials = await rawMaterialRepository.getAllRawMaterials();
      setState(() {
        _availableRawMaterials = rawMaterials
            .map((rawMaterial) => {
                  'id': rawMaterial.id,
                  'name': 'Insumo ${rawMaterial.name}',
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error al obtener los insumos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateRawMaterialQuantity(int rawMaterialIndex, double newQuantity) {
    setState(() {
      _selectedRawMaterials[rawMaterialIndex].quantity = newQuantity;
    });
  }

  void _addRawMaterial(Map<String, dynamic> rawMaterialData) {
    setState(() {
      _selectedRawMaterials.add(UsedRawMaterial(
        rawMaterialId: rawMaterialData['id'],
        quantity: 1.0,
        name: rawMaterialData['name'],
        recipeId: 1,
        userId: '',
      ));
    });
  }

  void _removeRawMaterial(int index) {
    setState(() {
      _selectedRawMaterials.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar insumos'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownSearch<String>.multiSelection(
                    items: _availableRawMaterials
                        .map((rawMaterial) => rawMaterial['name'] as String)
                        .toList(),
                    popupProps: const PopupPropsMultiSelection.menu(
                      showSelectedItems: true,
                    ),
                    onChanged: (selectedItems) {
                      setState(() {
                        _selectedRawMaterials = selectedItems
                            .map((name) => _availableRawMaterials.firstWhere(
                                (rawMaterial) => rawMaterial['name'] == name))
                            .map((rawMaterialData) => UsedRawMaterial(
                                  rawMaterialId: rawMaterialData['id'],
                                  quantity: 1.0,
                                  name: rawMaterialData['name'],
                                  recipeId: 1,
                                  userId: '',
                                ))
                            .toList();
                      });
                    },
                    selectedItems: _selectedRawMaterials
                        .map((rawMaterial) => rawMaterial.name)
                        .toList(),
                  ),
                  const SizedBox(height: 16.0),
                  ..._selectedRawMaterials.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final rawMaterial = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            child: Text(rawMaterial.name),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _updateRawMaterialQuantity(
                                  index, double.parse(value)),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Cantidad',
                              ),
                              controller: TextEditingController(
                                  text: rawMaterial.quantity.toString()),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeRawMaterial(index),
                            icon: const Icon(Icons.remove_circle),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            widget.onRawMaterialsSelected(_selectedRawMaterials);
            Navigator.pop(context);
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
