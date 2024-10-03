// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';

class MedidaForm extends StatefulWidget {
  final Function(String, String) onMedidaAgregada;
  final String? largeName;
  final String? shortName;

  const MedidaForm({
    super.key,
    required this.onMedidaAgregada,
    this.largeName,
    this.shortName,
  });

  @override
  _MedidaFormState createState() => _MedidaFormState();
}

class _MedidaFormState extends State<MedidaForm> {
  final _formKey = GlobalKey<FormState>();
  final _largeNameController = TextEditingController();
  final _shortNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.largeName != null) {
      _largeNameController.text = widget.largeName!;
    }
    if (widget.shortName != null) {
      _shortNameController.text = widget.shortName!;
    }
  }

  @override
  void dispose() {
    _largeNameController.dispose();
    _shortNameController.dispose();
    super.dispose();
  }

  void _agregarMedida() {
    if (_formKey.currentState!.validate()) {
      widget.onMedidaAgregada(
        _largeNameController.text,
        _shortNameController.text,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.largeName == null ? 'Agregar Medida' : 'Editar Medida',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _largeNameController,
              decoration: const InputDecoration(labelText: 'Nombre Largo'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un nombre largo';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _shortNameController,
              decoration: const InputDecoration(labelText: 'Nombre Corto'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un nombre corto';
                }
                return null;
              },
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
          onPressed: _agregarMedida,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.gradient2,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
