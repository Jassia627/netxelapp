// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/features/home/pages/components/forms/insumo_form.dart';
import 'package:netxelapp/main.dart';

class RawMaterialList extends StatefulWidget {
  const RawMaterialList({super.key});

  @override
  _RawMaterialListState createState() => _RawMaterialListState();
}

class _RawMaterialListState extends State<RawMaterialList> {
  final _client = supabase;
  List<Map<String, dynamic>> _rawMaterials = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRawMaterials();
  }

  Future<void> _fetchRawMaterials() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await _client
            .from('raw_materials')
            .select(
                '*, units_of_measures(large_name, short_name), providers(name)')
            .eq('active', true)
            .order('name');

        setState(() {
          _rawMaterials = response;
          _isLoading = false;
        });
      } else {
        // Manejar caso cuando no hay una sesión de usuario válida
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Manejar error
    }
  }

  Future<void> _addRawMaterial(
      String name, int unitOfMeasureId, int providerId) async {
    try {
      await _client.from('raw_materials').insert({
        'name': name,
        'unit_of_measure_id': unitOfMeasureId,
        'provider_id': providerId,
        'user_id': supabase.auth.currentUser?.id,
      });
      _fetchRawMaterials();
    } catch (e) {
      // Manejar error
    }
  }

  Future<void> _updateRawMaterial(
      int index, String name, int unitOfMeasureId, int providerId) async {
    try {
      final rawMaterialId = _rawMaterials[index]['id'];
      await _client.from('raw_materials').update({
        'name': name,
        'unit_of_measure_id': unitOfMeasureId,
        'provider_id': providerId,
        'user_id': supabase.auth.currentUser?.id,
      }).eq('id', rawMaterialId);
      _fetchRawMaterials();
    } catch (e) {
      // Manejar error
    }
  }

  Future<void> _deleteRawMaterial(int index) async {
    try {
      final rawMaterialId = _rawMaterials[index]['id'];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Eliminar insumo'),
            content: Text(
                '¿Estás seguro de eliminar el insumo "${_rawMaterials[index]['name']}"?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  await _client
                      .from('raw_materials')
                      .update({'active': false}).eq('id', rawMaterialId);
                  Navigator.of(context).pop();
                  _fetchRawMaterials();
                },
                child: const Text('Eliminar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Manejar error
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRawMaterials = _rawMaterials.where((rawMaterial) {
      final rawMaterialName = rawMaterial['name'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return rawMaterialName.contains(query);
    }).toList();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Buscar insumo',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredRawMaterials.length,
                    itemBuilder: (context, index) {
                      final rawMaterial = filteredRawMaterials[index];
                      return Card(
                        color: AppPallete.gradient2,
                        child: ListTile(
                          title: Text(rawMaterial['name']),
                          subtitle: Text(
                            'Unidad de Medida: ${rawMaterial['units_of_measures']['large_name']} (${rawMaterial['units_of_measures']['short_name']})\nProveedor: ${rawMaterial['providers']['name']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => RawMaterialForm(
                                      name: rawMaterial['name'],
                                      unitOfMeasureId:
                                          rawMaterial['unit_of_measure_id'],
                                      providerId: rawMaterial['provider_id'],
                                      onRawMaterialAdded:
                                          (name, unitOfMeasureId, providerId) =>
                                              _updateRawMaterial(index, name,
                                                  unitOfMeasureId, providerId),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteRawMaterial(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => RawMaterialForm(
                          onRawMaterialAdded: _addRawMaterial,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.gradient2),
                    child: const Text('Agregar Insumo'),
                  ),
                ),
              ],
            ),
    );
  }
}
