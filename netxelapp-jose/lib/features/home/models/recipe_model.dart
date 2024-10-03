// // ignore_for_file: unnecessary_null_comparison

// import 'package:netxelapp/features/home/Entities/recipe.dart';
// import 'package:netxelapp/main.dart';

// class SupabaseService {
//   final _client = supabase;

//   Future<List<Recipe>> fetchRecipes() async {
//     final response = await _client.from('recipes').select();
//     if (response != null) {
//       throw response;
//     }
//     return (response as List).map((e) => Recipe.fromMap(e)).toList();
//   }

//   Future<void> addRecipe(Recipe recipe) async {
//     final response = await _client.from('recipes').insert(recipe.toMap());
//     if (response.error != null) {
//       throw response.error!;
//     }
//   }

//   Future<void> addProducedProduct(RecipeProducedProduct product) async {
//     final response =
//         await _client.from('recipes_produced_products').insert(product.toMap());
//     if (response.error != null) {
//       throw response.error!;
//     }
//   }

//   Future<void> addUsedRawMaterial(UsedRawMaterial material) async {
//     final response =
//         await _client.from('used_raw_materials').insert(material.toMap());
//     if (response.error != null) {
//       throw response.error!;
//     }
//   }

//   Future<List<dynamic>> fetchProducts() async {
//     final response = await _client.from('products').select();
//     if (response != null) {
//       throw response;
//     }
//     return response;
//   }

//   Future<List<dynamic>> fetchRawMaterials() async {
//     final response = await _client.from('raw_materials').select();
//     if (response != null) {
//       throw response;
//     }
//     return response;
//   }
// }
