import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import '../../../Entities/planta.dart';

class PlantaForm extends StatefulWidget {
  final Function(Planta) onPlantaAgregada;
  final Planta? planta;
  final List<String> empleados;

  const PlantaForm(
      {super.key,
      required this.onPlantaAgregada,
      required this.empleados,
      this.planta});

  @override
  // ignore: library_private_types_in_public_api
  _PlantaFormState createState() => _PlantaFormState();
}

class _PlantaFormState extends State<PlantaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  String? _empleadoAsignado;

  @override
  void initState() {
    super.initState();
    if (widget.planta != null) {
      _nombreController.text = widget.planta!.nombre;
      _empleadoAsignado = widget.planta!.empleadoAsignado;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _agregarPlanta() {
    if (_formKey.currentState!.validate()) {
      final planta = Planta(
        nombre: _nombreController.text,
        empleadoAsignado: _empleadoAsignado!,
      );
      widget.onPlantaAgregada(planta);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.planta == null ? 'Agregar Planta' : 'Editar Planta'),
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
            DropdownButtonFormField<String>(
              value: _empleadoAsignado,
              decoration: const InputDecoration(labelText: 'Empleado Asignado'),
              items: widget.empleados.map((String empleado) {
                return DropdownMenuItem<String>(
                  value: empleado,
                  child: Text(empleado),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _empleadoAsignado = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor seleccione un empleado';
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
          onPressed: _agregarPlanta,
          style:
              ElevatedButton.styleFrom(backgroundColor: AppPallete.gradient2),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
