import 'package:netxelapp/main.dart';

class ExpensesService {
  final _supabaseClient = supabase;

  Future<void> addExpense(
      String description, double value, int categoryId) async {
    await _supabaseClient.from('expenses').insert({
      'description': description,
      'value': value,
      'expense_category_id': categoryId,
      'user_id': _supabaseClient.auth.currentUser!.id,
      'active': true,
    });
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final response = await _supabaseClient
        .from('expenses')
        .select('id, description, value, expense_category_id, created_at')
        .eq('active', true)
        .order('created_at', ascending: false);
    print('gastos:$response');
    return response;
  }

  Future<void> updateExpense(
      int id, String description, double value, int categoryId) async {
    await _supabaseClient.from('expenses').update({
      'description': description,
      'value': value,
      'expense_category_id': categoryId,
    }).eq('id', id);
  }

  Future<void> deleteExpense(int id) async {
    await _supabaseClient
        .from('expenses')
        .update({'active': false}).eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _supabaseClient
        .from('expenses_categories')
        .select('id, name')
        .eq('active', true)
        .order('name');
    return response;
  }
}
