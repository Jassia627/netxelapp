import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:netxelapp/features/home/Entities/recipe.dart';
import 'package:netxelapp/features/home/pages/production/production_service.dart';
import 'package:netxelapp/main.dart';

class RecipeProductionPage extends StatefulWidget {
  final int recipeId;

  const RecipeProductionPage({Key? key, required this.recipeId})
      : super(key: key);

  @override
  _RecipeProductionPageState createState() => _RecipeProductionPageState();
}

class _RecipeProductionPageState extends State<RecipeProductionPage> {
  final ProductionService _productionService = ProductionService();
  late Future<Recipe> _recipeFuture;
  String? _selectedEmployeeId;

  @override
  void initState() {
    super.initState();
    _recipeFuture = _productionService.getRecipeById(widget.recipeId);
  }

  Future<void> _processProduction(Recipe recipe) async {
    if (_selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un empleado')),
      );
      return;
    }

    try {
      await _productionService.processProduction(
        _selectedEmployeeId!,
        supabase.auth.currentUser!.id,
        {}, // No necesitamos productos seleccionados para una receta
        recipe.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producción procesada con éxito')),
      );
      context.pop(); // Volver a la página anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la producción: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Producción de Receta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final recipe = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Receta: ${recipe.name}',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                // Aquí puedes añadir más detalles de la receta
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Seleccionar Empleado'),
                  value: _selectedEmployeeId,
                  items: const [
                    DropdownMenuItem(value: 'emp1', child: Text('Empleado 1')),
                    DropdownMenuItem(value: 'emp2', child: Text('Empleado 2')),
                    // Añade más empleados según sea necesario
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedEmployeeId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _processProduction(recipe),
                  child: const Text('Iniciar Producción'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
