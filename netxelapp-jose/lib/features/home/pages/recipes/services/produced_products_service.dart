import 'package:netxelapp/features/home/Entities/produced_products.dart';
import 'package:netxelapp/main.dart';

class ProducedProductRepository {
  Future<List<ProducedProduct>> getProducedProductsByRecipeId(
      int recipeId) async {
    final response = await supabase
        .from('recipe_produced_products')
        .select()
        .eq('recipe_id', recipeId)
        .eq('active', true);
    final data = response;
    final producedProducts =
        (data as List).map((json) => ProducedProduct.fromMap(json)).toList();

    return producedProducts;
  }

  Future<bool> addProducedProduct(ProducedProduct producedProduct) async {
    final response = await supabase.from('recipe_produced_products').insert({
      'quantity': producedProduct.quantity,
      'product_id': producedProduct.productId,
      'recipe_id': producedProduct.recipeId,
      'user_id': producedProduct.userId
    });

    if (response != null) {
      throw Exception(
          'Error al agregar el producto producido: ${response.toString()}');
    }

    return response != null;
  }

  Future<void> updateProducedProducts(
      int recipeId, List<ProducedProduct> updatedProducts) async {
    // Eliminar todos los productos producidos existentes para la receta
    await supabase
        .from('recipe_produced_products')
        .delete()
        .eq('recipe_id', recipeId);

    // Insertar los nuevos productos producidos
    for (final product in updatedProducts) {
      await supabase.from('recipe_produced_products').insert({
        'recipe_id': recipeId,
        'product_id': product.productId,
        'quantity': product.quantity,
        'user_id': supabase.auth.currentSession?.user.id,
      });
    }
  }

  Future<bool> deleteProducedProduct(int id) async {
    final response =
        await supabase.from('recipe_produced_products').delete().eq('id', id);

    if (response != null) {
      throw Exception(
          'Error al eliminar el producto producido: ${response.toString()}');
    }

    return response != null;
  }

  Future<bool> deleteProducedProductsByRecipeId(int id) async {
    final response = await supabase
        .from('recipe_produced_products')
        .update({'active': false}).eq('recipe_id', id);

    if (response != null) {
      throw Exception(
          'Error al eliminar el producto producido: ${response.toString()}');
    }

    return response != null;
  }
}
