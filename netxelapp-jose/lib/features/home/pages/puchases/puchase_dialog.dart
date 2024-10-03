import 'package:flutter/material.dart';
import 'package:netxelapp/features/home/pages/puchases/puchases_services.dart';

class AddPurchaseDialog extends StatefulWidget {
  final VoidCallback onPurchaseAdded;

  const AddPurchaseDialog({Key? key, required this.onPurchaseAdded})
      : super(key: key);

  @override
  _AddPurchaseDialogState createState() => _AddPurchaseDialogState();
}

class _AddPurchaseDialogState extends State<AddPurchaseDialog> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _rawMaterials = [];
  Map<String, dynamic>? _selectedRawMaterial;
  String _unitOfMeasure = '';
  double _quantity = 0;
  double _price = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRawMaterials();
  }

  Future<void> _loadRawMaterials() async {
    try {
      final rawMaterials = await _supabaseService.getRawMaterials();
      setState(() {
        _rawMaterials = rawMaterials;
      });
    } catch (e) {
      _showErrorSnackBar('Error al cargar los insumos: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _savePurchase() async {
    if (_selectedRawMaterial == null) {
      _showErrorSnackBar('Por favor, selecciona un insumo');
      return;
    }

    if (_quantity <= 0 || _price <= 0) {
      _showErrorSnackBar('La cantidad y el precio deben ser mayores que cero');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print(
          "${_selectedRawMaterial!['id']} ${_selectedRawMaterial!['provider_id']} $_quantity $_price");

      await _supabaseService.insertRawMaterialPuchase(
        rawMaterialId: _selectedRawMaterial!['id'],
        providerId: _selectedRawMaterial!['provider_id'],
        quantity: _quantity,
        total: _price,
      );
      print(
          "${_selectedRawMaterial!['id']} ${_selectedRawMaterial!['provider_id']} $_quantity $_price");
      widget.onPurchaseAdded();
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
      _showErrorSnackBar('Error al guardar la compra: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Nueva Compra'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedRawMaterial,
              items: _rawMaterials.map((rawMaterial) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: rawMaterial,
                  child: Text(rawMaterial['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRawMaterial = value;
                  _unitOfMeasure = value?['unit_of_measure_id'] ?? '';
                });
              },
              decoration: InputDecoration(labelText: 'Insumo'),
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Cantidad',
                suffixText: _unitOfMeasure,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                _quantity = double.tryParse(value) ?? 0;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Precio de Compra'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                _price = double.tryParse(value) ?? 0;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _savePurchase,
          child: _isLoading ? CircularProgressIndicator() : Text('Guardar'),
        ),
      ],
    );
  }
}
