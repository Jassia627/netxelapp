import 'package:netxelapp/main.dart';

class SupabaseService {
  final _supabaseClient = supabase;

  Future<List<Map<String, dynamic>>> getRawMaterials() async {
    try {
      final response = await _supabaseClient
          .from('raw_materials')
          .select('id, name, unit_of_measure_id, provider_id');

      return response;
    } catch (e) {
      throw Exception('Error al obtener los insumos: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUnitsOfMeasure() async {
    try {
      final response = await _supabaseClient
          .from('units_of_measures')
          .select('id, large_name, short_name');

      return response;
    } catch (e) {
      throw Exception('Error al obtener las unidades de medida: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRawMaterialPuchases() async {
    try {
      final response =
          await _supabaseClient.from('raw_material_puchases').select();

      return response;
    } catch (e) {
      throw Exception('Error al obtener las compras: $e');
    }
  }

  Future<void> insertRawMaterialPuchase({
    required int rawMaterialId,
    required int providerId,
    required double quantity,
    required double total,
  }) async {
    try {
      await _supabaseClient.from('raw_material_puchases').insert({
        'raw_material_id': rawMaterialId,
        'provider_id': providerId,
        'quantity': quantity,
        'total': total,
      });
    } catch (e) {
      throw Exception('Error al insertar la compra: $e');
    }
  }
}
