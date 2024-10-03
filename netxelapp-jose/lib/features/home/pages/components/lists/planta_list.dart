import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/features/home/drawer.dart';
import 'package:netxelapp/features/home/pages/components/forms/planta_form.dart';
import '../../../Entities/planta.dart';

class PlantaList extends StatefulWidget {
  const PlantaList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PlantaListState createState() => _PlantaListState();
}

class _PlantaListState extends State<PlantaList> {
  final List<Planta> _plantas = [];
  final List<String> _empleados = [
    'Empleado 1',
    'Empleado 2',
    'Empleado 3',
    'Empleado 4',
    'Empleado 5'
  ];

  // Función para agregar planta
  void _agregarPlanta(Planta planta) {
    setState(() {
      _plantas.add(planta);
    });
  }

  // Función para editar planta
  void _editarPlanta(int index, Planta planta) {
    setState(() {
      _plantas[index] = planta;
    });
  }

  // Función para mostrar el cuadro de diálogo de confirmación
  void _mostrarConfirmacionEliminacion(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content:
              const Text('¿Estás seguro de que quieres eliminar esta planta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _eliminarPlanta(index);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  // Función para eliminar planta
  void _eliminarPlanta(int index) {
    setState(() {
      _plantas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Plantas'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _plantas.length,
              itemBuilder: (context, index) {
                final planta = _plantas[index];
                return Card(
                  color: AppPallete.gradient2,
                  child: ListTile(
                    title: Text(planta.nombre),
                    subtitle: Text(planta.empleadoAsignado),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de editar
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => PlantaForm(
                                planta: planta,
                                empleados: _empleados,
                                onPlantaAgregada: (updatedPlanta) =>
                                    _editarPlanta(index, updatedPlanta),
                              ),
                            );
                          },
                        ),
                        // Botón de eliminar
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _mostrarConfirmacionEliminacion(context, index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => PlantaForm(
                    empleados: _empleados,
                    onPlantaAgregada: _agregarPlanta,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.gradient2),
              child: const Text('Agregar Planta'),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
    );
  }
}
