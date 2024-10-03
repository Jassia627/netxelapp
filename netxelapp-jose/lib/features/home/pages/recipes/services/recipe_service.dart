import 'package:netxelapp/features/home/Entities/recipe.dart';
import 'package:netxelapp/main.dart';

class RecipeRepository {
  Future<List<Recipe>?> getAllRecipes() async {
    try {
      final response =
          await supabase.from('recipes').select().eq('active', true);

      final recipes =
          (response as List).map((json) => Recipe.fromMap(json)).toList();

      if (response.isNotEmpty) {
        return recipes;
      }
    } catch (e) {
      // ignore: avoid_print
      print('error fech : $e');
    }
    return null;
  }

  Future<Recipe?> getRecipeById(int id) async {
    final response =
        await supabase.from('recipes').select().eq('id', id).maybeSingle();

    if (response == null) {
      return null;
    }

    return Recipe.fromMap(response);
  }

  Future<int?> createRecipe(Recipe recipe) async {
    try {
      final response = await supabase
          .from('recipes')
          .insert({'name': recipe.name, 'user_id': recipe.userId})
          .select('id')
          .maybeSingle();

      if (response == null) {
        throw Exception('Error al crear la receta: ${response.toString()}');
      }
      return response['id'];
    } catch (e) {
      throw Exception('Creando: $e');
    }
  }

  Future<bool> updateRecipe(Recipe recipe) async {
    final response = await supabase
        .from('recipes')
        .update(recipe.toMap())
        .eq('id', recipe.id.toString())
        .maybeSingle();

    return response != null;
  }

  Future<bool> deleteRecipe(int id) async {
    final response = await supabase
        .from('recipes')
        .update({'active': false})
        .eq('id', id)
        .maybeSingle();

    if (response != null) {
      throw Exception('Error al eliminar la receta: ${response.toString()}');
    }

    return response != null;
  }
}
