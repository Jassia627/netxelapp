import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/features/home/pages/components/forms/receta_form.dart';
import '../../../Entities/receta.dart';

class RecetaList extends StatefulWidget {
  const RecetaList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RecetaListState createState() => _RecetaListState();
}

class _RecetaListState extends State<RecetaList> {
  final List<Receta> _recetas = [];
  final List<String> _insumos = [];
  final List<String> _productos = [];

  // Función para agregar receta
  void _agregarReceta(Receta receta) {
    setState(() {
      _recetas.add(receta);
    });
  }

  // Función para editar receta
  void _editarReceta(int index, Receta receta) {
    setState(() {
      _recetas[index] = receta;
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
              const Text('¿Estás seguro de que quieres eliminar esta receta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _eliminarReceta(index);
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

  // Función para eliminar receta
  void _eliminarReceta(int index) {
    setState(() {
      _recetas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _recetas.length,
              itemBuilder: (context, index) {
                final receta = _recetas[index];
                return Card(
                  color: AppPallete.gradient2,
                  child: ListTile(
                    title: Text(receta.nombre),
                    subtitle: Text(
                        'Insumos: ${receta.insumosUtilizados.join(', ')}\nProductos: ${receta.productosProducidos.join(', ')}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de editar
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => RecetaForm(
                                receta: receta,
                                insumos: _insumos,
                                productos: _productos,
                                onRecetaAgregada: (updatedReceta) =>
                                    _editarReceta(index, updatedReceta),
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
                  builder: (context) => RecetaForm(
                    insumos: _insumos,
                    productos: _productos,
                    onRecetaAgregada: _agregarReceta,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.gradient2),
              child: const Text('Agregar Receta'),
            ),
          ),
        ],
      ),
    );
  }
}
