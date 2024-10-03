import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import '../../../Entities/receta.dart';

class RecetaForm extends StatefulWidget {
  final Function(Receta) onRecetaAgregada;
  final Receta? receta;
  final List<String> insumos;
  final List<String> productos;

  const RecetaForm(
      {super.key,
      required this.onRecetaAgregada,
      required this.insumos,
      required this.productos,
      this.receta});

  @override
  // ignore: library_private_types_in_public_api
  _RecetaFormState createState() => _RecetaFormState();
}

class _RecetaFormState extends State<RecetaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  List<String> _insumosSeleccionados = [];
  List<String> _productosSeleccionados = [];

  @override
  void initState() {
    super.initState();
    if (widget.receta != null) {
      _nombreController.text = widget.receta!.nombre;
      _insumosSeleccionados = List.from(widget.receta!.insumosUtilizados);
      _productosSeleccionados = List.from(widget.receta!.productosProducidos);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _agregarReceta() {
    if (_formKey.currentState!.validate()) {
      final receta = Receta(
        nombre: _nombreController.text,
        insumosUtilizados: _insumosSeleccionados,
        productosProducidos: _productosSeleccionados,
      );
      widget.onRecetaAgregada(receta);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.receta == null ? 'Agregar Receta' : 'Editar Receta'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Selector de insumos
              _buildMultiSelectField(
                'Insumos Utilizados',
                widget.insumos,
                _insumosSeleccionados,
                (selected) {
                  setState(() {
                    _insumosSeleccionados = selected;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Selector de productos
              _buildMultiSelectField(
                'Productos Producidos',
                widget.productos,
                _productosSeleccionados,
                (selected) {
                  setState(() {
                    _productosSeleccionados = selected;
                  });
                },
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
          onPressed: _agregarReceta,
          style:
              ElevatedButton.styleFrom(backgroundColor: AppPallete.gradient2),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildMultiSelectField(
      String title,
      List<String> items,
      List<String> selectedItems,
      Function(List<String>) onSelectedItemsChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return ChoiceChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedItems.add(item);
                  } else {
                    selectedItems.remove(item);
                  }
                });
                onSelectedItemsChanged(selectedItems);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
