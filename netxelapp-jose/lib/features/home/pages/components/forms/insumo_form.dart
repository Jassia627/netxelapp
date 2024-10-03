// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/main.dart';

class RawMaterialForm extends StatefulWidget {
  final Function(String, int, int) onRawMaterialAdded;
  final String? name;
  final int? unitOfMeasureId;
  final int? providerId;

  const RawMaterialForm({
    super.key,
    required this.onRawMaterialAdded,
    this.name,
    this.unitOfMeasureId,
    this.providerId,
  });

  @override
  _RawMaterialFormState createState() => _RawMaterialFormState();
}

class _RawMaterialFormState extends State<RawMaterialForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int? _selectedUnitOfMeasureId;
  int? _selectedProviderId;
  List<Map<String, dynamic>> _unitsOfMeasure = [];
  List<Map<String, dynamic>> _providers = [];
  final _client = supabase;

  @override
  void initState() {
    super.initState();
    if (widget.name != null) {
      _nameController.text = widget.name!;
    }
    _selectedUnitOfMeasureId = widget.unitOfMeasureId;
    _selectedProviderId = widget.providerId;
    _fetchUnitsOfMeasure();
    _fetchProviders();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUnitsOfMeasure() async {
    try {
      final unitsOfMeasureResponse = await _client
          .from('units_of_measures')
          .select('id, large_name, short_name')
          .eq('active', true);

      setState(() {
        _unitsOfMeasure = unitsOfMeasureResponse.map((unitOfMeasure) {
          return {
            'id': unitOfMeasure['id'],
            'large_name': unitOfMeasure['large_name'],
            'short_name': unitOfMeasure['short_name'],
          };
        }).toList();
      });
    } catch (e) {
      // Manejar error
    }
  }

  Future<void> _fetchProviders() async {
    try {
      final providersResponse = await _client
          .from('providers')
          .select('id, name')
          .eq('user_id', supabase.auth.currentUser!.id);

      setState(() {
        _providers = providersResponse.map((provider) {
          return {
            'id': provider['id'],
            'name': provider['name'],
          };
        }).toList();
      });
    } catch (e) {
      // Manejar error
    }
  }

  void _addRawMaterial() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final unitOfMeasureId = _selectedUnitOfMeasureId;
      final providerId = _selectedProviderId;

      if (unitOfMeasureId != null && providerId != null) {
        widget.onRawMaterialAdded(name, unitOfMeasureId, providerId);
        Navigator.of(context).pop();
      } else {
        // Show an error message if either unit of measure or provider is null
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.name == null ? 'Agregar Insumo' : 'Editar Insumo',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre del Insumo'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un nombre de insumo';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _selectedUnitOfMeasureId,
              onChanged: (value) {
                setState(() {
                  _selectedUnitOfMeasureId = value;
                });
              },
              items: _unitsOfMeasure.map((unitOfMeasure) {
                return DropdownMenuItem<int>(
                  value: unitOfMeasure['id'],
                  child: Text(
                      '${unitOfMeasure['large_name']} (${unitOfMeasure['short_name']})'),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Unidad de Medida',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _selectedProviderId,
              onChanged: (value) {
                setState(() {
                  _selectedProviderId = value;
                });
              },
              items: _providers.map((provider) {
                return DropdownMenuItem<int>(
                  value: provider['id'],
                  child: Text(provider['name']),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Proveedor',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _addRawMaterial,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.gradient2,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
