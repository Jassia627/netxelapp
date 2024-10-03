import 'package:netxelapp/main.dart';

class ProductRepository {
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final response =
          await supabase.from('products').select().eq('active', true);

      return response.cast<Map<String, dynamic>>();
    } on Exception catch (e) {
      throw Exception('Error al obtener los productos: $e');
    }
  }
}
