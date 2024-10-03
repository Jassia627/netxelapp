// ignore_for_file: avoid_print

import 'package:netxelapp/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String username = "";
int factoryId = 0;

Future<String> getUserNameByID(String userId) async {
  try {
    final response = await supabase
        .from('profiles')
        .select('name')
        .eq('id', userId)
        .maybeSingle();

    if (response != null && response['name'] != null) {
      return response['name'] as String;
    } else {
      print('No se encontró el nombre del usuario o el campo está vacío');
      return 'Usuario';
    }
  } catch (e) {
    print('Error al obtener el nombre de usuario: $e');
    print('ID de usuario: $userId');
    if (e is PostgrestException) {
      print('Error de Supabase: ${e.message}');
      print('Detalles: ${e.details}');
    }
    return 'Usuario';
  }
}

Future<int> getFactory(String? userId) async {
  try {
    final response = await supabase
        .from('factories')
        .select('id')
        .eq('user_id', userId!)
        .maybeSingle();

    return response?['id'];
  } catch (e) {
    // Manejar cualquier excepción que ocurra durante la obtención del nombre
    // Puedes lanzar la excepción nuevamente o devolver un valor predeterminado
    throw Exception(e.toString());
  }
}
