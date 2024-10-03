// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/features/home/pages/components/forms/medida_form.dart';
import 'package:netxelapp/main.dart';

class MedidaList extends StatefulWidget {
  const MedidaList({super.key});

  @override
  _MedidaListState createState() => _MedidaListState();
}

class _MedidaListState extends State<MedidaList> {
  final _client = supabase;
  List<Map<String, dynamic>> _medidas = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMedidas();
  }

  Future<void> _fetchMedidas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _client
          .from('units_of_measures')
          .select('*')
          .eq('active', true)
          .order('large_name');

      setState(() {
        _medidas = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addMedida(String largeName, String shortName) async {
    try {
      await _client.from('units_of_measures').insert({
        'large_name': largeName,
        'short_name': shortName,
        'user_id': supabase.auth.currentUser?.id,
      });
      _fetchMedidas();
    } catch (e) {
      // Manejar error
    }
  }

  Future<void> _updateMedida(
      int index, String largeName, String shortName) async {
    try {
      final medidaId = _medidas[index]['id'];
      await _client.from('units_of_measures').update({
        'large_name': largeName,
        'short_name': shortName,
      }).eq('id', medidaId);
      _fetchMedidas();
    } catch (e) {
      // Manejar error
    }
  }

  Future<void> _deleteMedida(int index) async {
    try {
      final medidaId = _medidas[index]['id'];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Eliminar medida'),
            content: Text(
                '¿Estás seguro de eliminar la medida "${_medidas[index]['large_name']}"?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  await _client.from('units_of_measures').update({
                    'active': false,
                  }).eq('id', medidaId);
                  Navigator.of(context).pop();
                  _fetchMedidas();
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
    final filteredMedidas = _medidas.where((medida) {
      final largeName = medida['large_name'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return largeName.contains(query);
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
                      labelText: 'Buscar medida',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredMedidas.length,
                    itemBuilder: (context, index) {
                      final medida = filteredMedidas[index];
                      return Card(
                        color: AppPallete.gradient2,
                        child: ListTile(
                          title: Text(medida['large_name']),
                          subtitle: Text(medida['short_name']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => MedidaForm(
                                      largeName: medida['large_name'],
                                      shortName: medida['short_name'],
                                      onMedidaAgregada: (updatedLargeName,
                                              updatedShortName) =>
                                          _updateMedida(index, updatedLargeName,
                                              updatedShortName),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteMedida(index),
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
                        builder: (context) => MedidaForm(
                          onMedidaAgregada: _addMedida,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.gradient2),
                    child: const Text('Agregar Medida'),
                  ),
                ),
              ],
            ),
    );
  }
}
