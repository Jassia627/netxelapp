// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';

class EmployeeForm extends StatefulWidget {
  final Function(String, String, String, String)? onEmployeeAdded;
  final Function(String, String, String, String)? onEmployeeUpdated;
  final Map<String, dynamic>? employee;

  const EmployeeForm({
    super.key,
    this.onEmployeeAdded,
    this.onEmployeeUpdated,
    this.employee,
  });

  @override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _identificationController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!['name'];
      _lastnameController.text = widget.employee!['lastname'];
      _identificationController.text = widget.employee!['identification'];
      _phoneController.text = widget.employee!['phone'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _identificationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final lastname = _lastnameController.text;
      final identification = _identificationController.text;
      final phone = _phoneController.text;

      if (widget.onEmployeeAdded != null) {
        widget.onEmployeeAdded!(name, lastname, identification, phone);
      } else if (widget.onEmployeeUpdated != null) {
        widget.onEmployeeUpdated!(name, lastname, identification, phone);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.employee == null ? 'Agregar Empleado' : 'Editar Empleado',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un nombre';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _lastnameController,
              decoration: const InputDecoration(labelText: 'Apellido'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un apellido';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _identificationController,
              decoration: const InputDecoration(labelText: 'Identificación'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una identificación';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
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
      actions: [
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
    );
  }
}
