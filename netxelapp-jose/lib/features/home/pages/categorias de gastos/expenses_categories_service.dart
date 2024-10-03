import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseCategoriesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _supabase
          .from('expenses_categories')
          .select()
          .order('name', ascending: true);
      print('cate: $response');

      return response;
    } catch (e) {
      throw ('Error al obtener categorías: $e');
    }
  }

  Future<void> addCategory(String name) async {
    try {
      await _supabase.from('expenses_categories').insert({
        'name': name,
        'user_id': _supabase.auth.currentUser!.id,
      });
    } catch (e) {
      debugPrint('Error al agregar categoría: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(int id, String name) async {
    try {
      await _supabase.from('expenses_categories').update({
        'name': name,
      }).eq('id', id);
    } catch (e) {
      debugPrint('Error al actualizar categoría: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _supabase.from('expenses_categories').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error al eliminar categoría: $e');
      rethrow;
    }
  }
}
