import 'package:netxelapp/features/home/Entities/raw_materials.dart';
import 'package:netxelapp/main.dart';

class RawMaterialRepository {
  Future<List<RawMaterial>> getAllRawMaterials() async {
    final response =
        await supabase.from('raw_materials').select().eq('active', true);

    final rawMaterials =
        (response as List).map((json) => RawMaterial.fromMap(json)).toList();

    return rawMaterials;
  }
}
