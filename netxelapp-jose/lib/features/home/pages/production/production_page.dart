import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/features/home/Entities/recipe.dart';
import 'package:netxelapp/features/home/Entities/product.dart';
import 'package:netxelapp/features/home/pages/production/production_service.dart';
import 'package:netxelapp/main.dart';

class ProductionPage extends StatefulWidget {
  const ProductionPage({Key? key}) : super(key: key);

  @override
  _ProductionPageState createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProductionService _productionService = ProductionService();
  List<Recipe> _recipes = [];
  List<Product> _products = [];
  final Map<int, int> _selectedProducts = {};
  double _totalProduction = 0.0;
  String? _selectedEmployeeId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadRecipes(),
        _loadProducts(),
      ]);
    } catch (e) {
      _showErrorSnackBar('Error al cargar datos iniciales: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRecipes() async {
    _recipes = await _productionService.getRecipes();
    if (mounted) setState(() {});
  }

  Future<void> _loadProducts() async {
    _products = await _productionService.getProducts();
    if (mounted) setState(() {});
  }

  void _addProductToProduction(Product product, int quantity) {
    setState(() {
      _selectedProducts[product.id] =
          (_selectedProducts[product.id] ?? 0) + quantity;
      _totalProduction += product.productionCost * quantity;
    });
  }

  void _removeProductFromProduction(int productId) {
    setState(() {
      Product product = _products.firstWhere((p) => p.id == productId);
      int currentQuantity = _selectedProducts[productId] ?? 0;
      if (currentQuantity > 1) {
        _selectedProducts[productId] = currentQuantity - 1;
        _totalProduction -= product.productionCost;
      } else {
        _selectedProducts.remove(productId);
        _totalProduction -= product.productionCost * currentQuantity;
      }
    });
  }

  Future<void> _processProduction() async {
    if (_selectedEmployeeId == null) {
      _showErrorSnackBar('Por favor, selecciona un empleado');
      return;
    }

    if (_selectedProducts.isEmpty) {
      _showErrorSnackBar('Por favor, selecciona al menos un producto');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _productionService.processProduction(_selectedEmployeeId!,
          supabase.auth.currentUser!.id, _selectedProducts, null);

      if (mounted) {
        setState(() {
          _selectedProducts.clear();
          _totalProduction = 0.0;
          _selectedEmployeeId = null;
        });
        _showSuccessSnackBar('Producción procesada con éxito');
      }
    } catch (e) {
      _showErrorSnackBar('Error al procesar la producción: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startProductionWithRecipe(Recipe recipe) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar producción'),
          content: Text(
              '¿Estás seguro que deseas producir la receta "${recipe.name}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Producir'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _productionService.newProduction(recipe.id!);
        if (mounted) {
          _showSuccessSnackBar('Producción realizada con éxito');
          await _loadInitialData();
        }
      } catch (e) {
        _showErrorSnackBar('Error al realizar la producción: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  Widget _buildRecipeTab() {
    return ListView.builder(
      itemCount: _recipes.length,
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        return ExpansionTile(
          title: Text(recipe.name),
          subtitle: Text('ID: ${recipe.id}'),
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _productionService.getRecipeDetails(recipe.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final details = snapshot.data!;
                return Column(
                  children: details.map((detail) {
                    final product = detail['products'] as Map<String, dynamic>;
                    return ListTile(
                      title: Text(product['name']),
                      subtitle: Text('Cantidad: ${detail['quantity']}'),
                    );
                  }).toList(),
                );
              },
            ),
            ElevatedButton(
              onPressed:
                  _isLoading ? null : () => _startProductionWithRecipe(recipe),
              child: const Text('Producir'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFreeProductionTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              int selectedQuantity = _selectedProducts[product.id] ?? 0;
              return Card(
                color: AppPallete.gradient2,
                child: ListTile(
                  title: Text(product.name),
                  subtitle:
                      Text('Costo de producción: \$${product.productionCost}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: selectedQuantity > 0
                            ? () => _removeProductFromProduction(product.id)
                            : null,
                      ),
                      Text('$selectedQuantity'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addProductToProduction(product, 1),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Card(
          color: AppPallete.gradient1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                    'Total de producción: \$${_totalProduction.toStringAsFixed(2)}'),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Seleccionar Empleado'),
                  value: _selectedEmployeeId,
                  items: const [
                    DropdownMenuItem(value: 'emp1', child: Text('Empleado 1')),
                    DropdownMenuItem(value: 'emp2', child: Text('Empleado 2')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedEmployeeId = value;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _processProduction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.gradient2,
                  ),
                  child: const Text('Procesar Producción'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Material(
                  color: AppPallete.backgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Recetas'),
                      Tab(text: 'Producción Libre'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRecipeTab(),
                      _buildFreeProductionTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
