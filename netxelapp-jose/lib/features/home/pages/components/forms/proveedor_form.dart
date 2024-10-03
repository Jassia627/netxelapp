// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';

class ProviderForm extends StatefulWidget {
  final Function(String, String)? onProviderAdded;
  final Function(String, String)? onProviderUpdated;
  final Map<String, dynamic>? provider;

  const ProviderForm({
    super.key,
    this.onProviderAdded,
    this.onProviderUpdated,
    this.provider,
  });

  @override
  _ProviderFormState createState() => _ProviderFormState();
}

class _ProviderFormState extends State<ProviderForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.provider != null) {
      _nameController.text = widget.provider!['name'];
      _phoneController.text = widget.provider!['phone'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final phone = _phoneController.text;

      if (widget.onProviderAdded != null) {
        widget.onProviderAdded!(name, phone);
      } else if (widget.onProviderUpdated != null) {
        widget.onProviderUpdated!(name, phone);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.provider == null ? 'Agregar Proveedor' : 'Editar Proveedor',
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: IntrinsicHeight(
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration:
                              const InputDecoration(labelText: 'Nombre'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese un nombre';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _phoneController,
                          decoration:
                              const InputDecoration(labelText: 'Teléfono'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese un número de teléfono';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.gradient2,
                      ),
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
