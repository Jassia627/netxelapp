// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/main.dart';

class ProductoForm extends StatefulWidget {
  final Function(String, double, double, int, int, int) onProductoAgregado;
  final String? productName;
  final double? salePrice;
  final double? productionPrice;
  final int? presentationQuantity;
  final int? categoryId;
  final int? unitOfMeasureId;

  const ProductoForm({
    super.key,
    required this.onProductoAgregado,
    this.productName,
    this.salePrice,
    this.productionPrice,
    this.presentationQuantity,
    this.categoryId,
    this.unitOfMeasureId,
  });

  @override
  _ProductoFormState createState() => _ProductoFormState();
}

class _ProductoFormState extends State<ProductoForm> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _productionPriceController = TextEditingController();
  final _presentationQuantityController = TextEditingController();
  int? _selectedCategoryId;
  int? _selectedUnitOfMeasureId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _unitsOfMeasure = [];
  final _client = supabase;

  @override
  void initState() {
    super.initState();
    if (widget.productName != null) {
      _productNameController.text = widget.productName!;
    }
    if (widget.salePrice != null) {
      _salePriceController.text = widget.salePrice.toString();
    }
    if (widget.productionPrice != null) {
      _productionPriceController.text = widget.productionPrice.toString();
    }
    if (widget.presentationQuantity != null) {
      _presentationQuantityController.text =
          widget.presentationQuantity.toString();
    }
    _selectedCategoryId = widget.categoryId;
    _selectedUnitOfMeasureId = widget.unitOfMeasureId;
    _fetchCategories();
    _fetchUnitsOfMeasure();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _salePriceController.dispose();
    _productionPriceController.dispose();
    _presentationQuantityController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final categoriesResponse = await _client
          .from('products_categories')
          .select('id, category_name')
          .eq('active', true);

      setState(() {
        _categories = categoriesResponse.map((category) {
          return {
            'id': category['id'],
            'category_name': category['category_name'],
          };
        }).toList();
      });
    } catch (e) {
      // Manejar error
    }
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

  void _agregarProducto() {
    if (_formKey.currentState!.validate()) {
      final productName = _productNameController.text;
      final salePrice = double.parse(_salePriceController.text);
      final productionPrice = double.parse(_productionPriceController.text);
      final presentationQuantity =
          int.parse(_presentationQuantityController.text);
      final categoryId = _selectedCategoryId;
      final unitOfMeasureId = _selectedUnitOfMeasureId;

      if (categoryId != null && unitOfMeasureId != null) {
        widget.onProductoAgregado(
          productName,
          salePrice,
          productionPrice,
          presentationQuantity,
          categoryId,
          unitOfMeasureId,
        );
        Navigator.of(context).pop();
      } else {
        // Show an error message if either category or unit of measure is null
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.productName == null ? 'Agregar Producto' : 'Editar Producto',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _productNameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del Producto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre de producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _salePriceController,
                decoration: const InputDecoration(labelText: 'Precio de Venta'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un precio de venta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _productionPriceController,
                decoration:
                    const InputDecoration(labelText: 'Precio de Producción'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un precio de producción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _presentationQuantityController,
                decoration: const InputDecoration(
                    labelText: 'Cantidad de Presentación'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una cantidad de presentación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                items: _categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category['id'],
                    child: Text(category['category_name']),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                ),
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
                    child: Text(' (${unitOfMeasure['short_name']})'),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Unidad de Medida',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _agregarProducto,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.gradient2,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
