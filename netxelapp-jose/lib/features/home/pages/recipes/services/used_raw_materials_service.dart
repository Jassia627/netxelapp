import 'package:netxelapp/features/home/Entities/used_raw_material.dart';
import 'package:netxelapp/main.dart';

class UsedRawMaterialRepository {
  Future<List<UsedRawMaterial>> getUsedRawMaterialsByRecipeId(
      int recipeId) async {
    try {
      final response = await supabase
          .from('used_raw_materials')
          .select()
          .eq('recipe_id', recipeId)
          .eq('active', true);

      final data = response;

      final usedRawMaterials =
          (data as List).map((json) => UsedRawMaterial.fromMap(json)).toList();

      return usedRawMaterials;
    } catch (e) {
      throw Exception('Error al obtener los insumos utilizados: $e');
    }
  }

  Future<bool> addUsedRawMaterial(UsedRawMaterial usedRawMaterial) async {
    final response = await supabase.from('used_raw_materials').insert({
      'quantity': usedRawMaterial.quantity,
      'raw_material_id': usedRawMaterial.rawMaterialId,
      'recipe_id': usedRawMaterial.recipeId,
      'user_id': usedRawMaterial.userId
    });

    if (response != null) {
      throw Exception(
          'Error al agregar el insumo utilizado: ${response.toString()}');
    }

    return response != null;
  }

  Future<void> updateUsedRawMaterials(
      int recipeId, List<UsedRawMaterial> updatedRawMaterials) async {
    // Eliminar todos los insumos utilizados existentes para la receta
    await supabase
        .from('used_raw_materials')
        .delete()
        .eq('recipe_id', recipeId);

    // Insertar los nuevos insumos utilizados
    for (final rawMaterial in updatedRawMaterials) {
      await supabase.from('used_raw_materials').insert({
        'recipe_id': recipeId,
        'raw_material_id': rawMaterial.rawMaterialId,
        'quantity': rawMaterial.quantity,
        'user_id': supabase.auth.currentSession?.user.id,
      });
    }
  }

  Future<bool> deleteUsedRawMaterial(int id) async {
    final response =
        await supabase.from('used_raw_materials').delete().eq('id', id);

    if (response != null) {
      throw Exception(
          'Error al eliminar el insumo utilizado: ${response.toString()}');
    }

    return response != null;
  }

  Future<bool> deleteUsedRawMaterialsByRecipeId(int id) async {
    final response = await supabase
        .from('used_raw_materials')
        .update({'active': false}).eq('recipe_id', id);

    if (response != null) {
      throw Exception(
          'Error al eliminar el insumo utilizado: ${response.toString()}');
    }

    return response != null;
  }
}
