import 'package:netxelapp/features/home/Entities/product.dart';
import 'package:netxelapp/features/home/Entities/recipe.dart';
import 'package:netxelapp/features/home/pages/recipes/recipes_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Recipe>> getRecipes() async {
    final response = await _supabase.from('recipes').select().order('name');

    return (response as List)
        .map((recipeData) => Recipe.fromMap(recipeData))
        .toList();
  }

  Future<List<Product>> getProducts() async {
    final response = await _supabase.from('products').select().order('name');
    print('Productos: $response');

    return response.map((data) => Product.fromMap(data)).toList();
    // return response.map((data) => Client.fromMap(data)).toList();
  }

  Future<void> newProduction(int recipeId) async {
    final produccionId = await _supabase
        .from('production')
        .insert({'recipe_id': recipeId, 'user_id': userId}).select('id');
    try {
      // Obtener los productos y cantidades de la receta
      final productos = await _supabase
          .from('recipe_produced_products')
          .select('product_id, quantity')
          .eq('recipe_id', recipeId);
      final insumos = await _supabase
          .from('used_raw_materials')
          .select()
          .eq('recipe_id', recipeId);

      // Actualizar el stock de cada producto
      for (var producto in productos) {
        final productId = producto['product_id'];
        final quantity = producto['quantity'];
        //agregando los productos a la tabla products_productions_details
        await _supabase.from('products_productions_details').insert({
          'recipe_id': recipeId,
          'user_id': userId,
          'production_id': produccionId[0]['id'],
          'product_id': productId
        });

        // Obtener el stock actual
        final currentStock = await _supabase
            .from('products')
            .select('stock_quantity')
            .eq('id', productId)
            .single();

        // Calcular el nuevo stock
        final newStock = (currentStock['stock_quantity'] ?? 0) + quantity;

        // Actualizar el stock
        await _supabase
            .from('products')
            .update({'stock_quantity': newStock}).eq('id', productId);
      }
      for (var insumo in insumos) {
        final insumoId = insumo['id'];
        final quantity = insumo['quantity'];
        await _supabase.from('raw_material_productions_details').insert({
          'recipe_id': recipeId,
          'user_id': userId,
          'production_id': produccionId[0]['id'],
          'raw_material_id': insumoId
        });

        // Obtener el stock actual
        final currentStock = await _supabase
            .from('raw_materials')
            .select('stock_quantity')
            .eq('id', insumoId)
            .single();

        // Calcular el nuevo stock
        final newStock = (currentStock['stock_quantity'] ?? 0) - quantity;

        // Actualizar el stock
        await _supabase
            .from('raw_materials')
            .update({'stock_quantity': newStock}).eq('id', insumoId);
      }

      // Insertar la producción en la tabla production
    } catch (e) {
      print(e);
      throw Exception('Failed to create production: $e');
    }
  }

  Future<void> processProduction(String employeeId, String userId,
      Map<int, int> selectedProducts, int? recipeId) async {
    try {
      // Start a Supabase transaction
      return await _supabase.rest.rpc('process_production', params: {
        'p_employee_id': employeeId,
        'p_user_id': userId,
        'p_recipe_id': recipeId,
        'p_products': selectedProducts.entries
            .map((e) => {
                  'product_id': e.key,
                  'quantity': e.value,
                })
            .toList(),
      });
    } catch (e) {
      throw Exception('Failed to process production: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRecipeDetails(int recipeId) async {
    final response = await _supabase
        .from('recipe_produced_products')
        .select('*, products(*)')
        .eq('recipe_id', recipeId);

    return response as List<Map<String, dynamic>>;
  }

  Future<Recipe> getRecipeById(int recipeId) async {
    final response =
        await _supabase.from('recipes').select().eq('id', recipeId).single();

    return Recipe.fromMap(response);
  }
}
