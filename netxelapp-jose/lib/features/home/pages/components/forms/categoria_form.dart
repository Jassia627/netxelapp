// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';

class CategoriaForm extends StatefulWidget {
  final Function(String) onCategoriaAgregada;
  final String? categoria;

  const CategoriaForm({
    super.key,
    required this.onCategoriaAgregada,
    this.categoria,
  });

  @override
  _CategoriaFormState createState() => _CategoriaFormState();
}

class _CategoriaFormState extends State<CategoriaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      _nombreController.text = widget.categoria!;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _agregarCategoria() {
    if (_formKey.currentState!.validate()) {
      widget.onCategoriaAgregada(_nombreController.text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.categoria == null ? 'Agregar Categoría' : 'Editar Categoría',
      ),
      content: Form(
        key: _formKey,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _agregarCategoria,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.gradient2,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
