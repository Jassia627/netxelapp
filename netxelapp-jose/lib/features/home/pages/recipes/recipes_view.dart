// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/features/home/Entities/produced_products.dart';
import 'package:netxelapp/features/home/Entities/recipe.dart';
import 'package:netxelapp/features/home/Entities/used_raw_material.dart';
import 'package:netxelapp/features/home/pages/recipes/dialogs/product_picker_dialog.dart';
import 'package:netxelapp/features/home/pages/recipes/dialogs/raw_materials_picker_dialog.dart';
import 'package:netxelapp/features/home/pages/recipes/services/produced_products_service.dart';
import 'package:netxelapp/features/home/pages/recipes/services/recipe_service.dart';
import 'package:netxelapp/features/home/pages/recipes/services/used_raw_materials_service.dart';
import 'package:netxelapp/main.dart';

final userId = supabase.auth.currentSession?.user.id;

class RecipeView extends StatefulWidget {
  const RecipeView({super.key});

  @override
  _RecipeViewState createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  final RecipeRepository _recipeRepository = RecipeRepository();
  final ProducedProductRepository _producedProductRepository =
      ProducedProductRepository();
  final UsedRawMaterialRepository _usedRawMaterialRepository =
      UsedRawMaterialRepository();
  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      final recipes = await _recipeRepository.getAllRecipes();
      setState(() {
        _recipes = recipes!;
        _filteredRecipes = recipes;
      });
      print('recetas: $_recipes');
    } catch (e) {
      print('Error al obtener las recetas: $e');
    }
  }

  Future<void> _showAddRecipeDialog() async {
    final recipeNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar receta'),
          content: TextField(
            controller: recipeNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la receta',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final recipeName = recipeNameController.text.trim();
                if (recipeName.isNotEmpty) {
                  try {
                    // Reemplaza con el ID del usuario actual
                    final recipe = Recipe(name: recipeName, userId: userId);
                    final recipeId =
                        await _recipeRepository.createRecipe(recipe);
                    if (recipeId != null) {
                      _fetchRecipes();

                      // Mostrar el diálogo para seleccionar productos
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ProductPickerDialog(
                            selectedProducts: const [], // Lista vacía inicialmente
                            onProductsSelected: (selectedProducts) async {
                              // Guardar los productos seleccionados en la base de datos
                              for (final product in selectedProducts) {
                                product.recipeId = recipeId;
                                product.userId =
                                    userId!; // Reemplaza con el ID del usuario actual
                                await _producedProductRepository
                                    .addProducedProduct(product);
                              }
                            },
                          );
                        },
                      );

                      // Mostrar el diálogo para seleccionar insumos
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return RawMaterialPickerDialog(
                            selectedRawMaterials: [], // Lista vacía inicialmente
                            onRawMaterialsSelected:
                                (selectedRawMaterials) async {
                              // Guardar los insumos seleccionados en la base de datos
                              for (final rawMaterial in selectedRawMaterials) {
                                rawMaterial.recipeId = recipeId;
                                rawMaterial.userId =
                                    userId!; // Reemplaza con el ID del usuario actual
                                await _usedRawMaterialRepository
                                    .addUsedRawMaterial(rawMaterial);
                              }
                            },
                          );
                        },
                      );
                    }
                  } catch (e) {
                    print('Error al crear la receta: $e');
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecipe(int recipeId) async {
    try {
      // Eliminar los productos producidos asociados a la receta
      await _producedProductRepository
          .deleteProducedProductsByRecipeId(recipeId);

      // Eliminar los insumos utilizados asociados a la receta
      await _usedRawMaterialRepository
          .deleteUsedRawMaterialsByRecipeId(recipeId);

      // Eliminar la receta
      await _recipeRepository.deleteRecipe(recipeId);

      // Actualizar la lista de recetas después de eliminar
      _fetchRecipes();
    } catch (e) {
      print('Error al eliminar la receta: $e');
    }
  }

  Future<void> _showDeleteRecipeDialog(int recipeId) async {
    bool? deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar receta'),
          content:
              const Text('¿Estás seguro de que deseas eliminar esta receta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed == true) {
      await _deleteRecipe(recipeId);
    }
  }

  Future<void> _showEditRecipeDialog(int recipeId) async {
    if (!mounted) return; // Verifica si el widget aún está montado

    final Recipe? recipe = await _recipeRepository.getRecipeById(recipeId);
    if (recipe == null) {
      print('Error al obtener la receta con ID: $recipeId');
      return;
    }

    final recipeNameController = TextEditingController(text: recipe.name);
    List<ProducedProduct> producedProducts = await _producedProductRepository
        .getProducedProductsByRecipeId(recipeId);
    List<UsedRawMaterial> usedRawMaterials = await _usedRawMaterialRepository
        .getUsedRawMaterialsByRecipeId(recipeId);

    List<ProducedProduct> updatedProducts =
        await showDialog<List<ProducedProduct>>(
              context: context,
              builder: (BuildContext context) {
                if (!mounted) {
                  return const SizedBox.shrink(); // Retorna un widget vacío
                }
                return ProductPickerDialog(
                  selectedProducts: producedProducts,
                  onProductsSelected: (selectedProducts) {
                    Navigator.pop(context, selectedProducts);
                  },
                );
              },
            ) ??
            [];

    List<UsedRawMaterial> updatedRawMaterials =
        await showDialog<List<UsedRawMaterial>>(
              context: context,
              builder: (BuildContext context) {
                if (!mounted) {
                  return const SizedBox.shrink(); // Retorna un widget vacío
                }
                return RawMaterialPickerDialog(
                  selectedRawMaterials: usedRawMaterials,
                  onRawMaterialsSelected: (selectedRawMaterials) {
                    Navigator.pop(context, selectedRawMaterials);
                  },
                );
              },
            ) ??
            [];

    // Mostrar el diálogo para editar el nombre de la receta
    final updatedName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar receta'),
          content: TextField(
            controller: recipeNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la receta',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, recipeNameController.text.trim());
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (updatedName != null && updatedName.isNotEmpty) {
      try {
        final updatedRecipe = Recipe(
          id: recipe.id,
          name: updatedName,
          userId: userId,
        );
        print('Usuario: ${updatedRecipe.userId}');
        await _recipeRepository.updateRecipe(updatedRecipe);

        // Actualizar los productos producidos en la base de datos
        await _producedProductRepository.updateProducedProducts(
            recipeId, updatedProducts);

        // Actualizar los insumos utilizados en la base de datos
        await _usedRawMaterialRepository.updateUsedRawMaterials(
            recipeId, updatedRawMaterials);

        _fetchRecipes();
        print(updatedRecipe);
      } catch (e) {
        print('Error al actualizar la receta: $e');
      }
    }
  }

  Future<void> _showRecipeDetailsDialog(int recipeId) async {
    final Recipe? recipe = await _recipeRepository.getRecipeById(recipeId);
    if (recipe == null) {
      print('Error al obtener la receta con ID: $recipeId');
      return;
    }

    final producedProducts = await _producedProductRepository
        .getProducedProductsByRecipeId(recipeId);
    final usedRawMaterials = await _usedRawMaterialRepository
        .getUsedRawMaterialsByRecipeId(recipeId);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la receta: ${recipe.name}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Productos producidos:'),
              ...producedProducts.map(
                (product) => Text(
                  '- ${product.quantity} unidades de producto ${product.name}',
                ),
              ),
              const SizedBox(height: 16.0),
              const Text('Insumos utilizados:'),
              ...usedRawMaterials.map(
                (rawMaterial) => Text(
                  '- ${rawMaterial.quantity} unidades de insumo ${rawMaterial.name}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () => _showEditRecipeDialog(recipe.id!),
              child: const Text('Editar'),
            ),
          ],
        );
      },
    );
  }

  final _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar receta...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _filteredRecipes = _recipes
                      .where((recipe) => recipe.name
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _filteredRecipes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 2.0),
                  child: Card(
                    color: AppPallete.gradient2,
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ClipPath(
                      clipper: ShapeBorderClipper(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppPallete.gradient3,
                              width: 4.0,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          title: Text(
                            recipe.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _showRecipeDetailsDialog(recipe.id!),
                                icon: const Icon(Icons.info),
                                tooltip: 'Ver detalles',
                              ),
                              IconButton(
                                onPressed: () =>
                                    _showDeleteRecipeDialog(recipe.id!),
                                icon: const Icon(Icons.delete),
                                tooltip: 'Eliminar receta',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecipeDialog,
        backgroundColor: AppPallete.gradient2,
        child: const Icon(Icons.add),
      ),
    );
  }
}
