// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/main.dart';

class RawMaterialStock extends StatefulWidget {
  const RawMaterialStock({super.key});

  @override
  _RawMaterialStockState createState() => _RawMaterialStockState();
}

class _RawMaterialStockState extends State<RawMaterialStock> {
  final _client = supabase;
  List<Map<String, dynamic>> _rawMaterials = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRawmaterials();
  }

  Future<void> _fetchRawmaterials() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _client
          .from('raw_materials')
          .select('*,units_of_measures(large_name, short_name)')
          .eq('active', true)
          .order('name');

      setState(() {
        _rawMaterials = response;
        _isLoading = false;
      });
      //print('hola$response');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      //print('error$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRawMaterials = _rawMaterials.where((rawMaterial) {
      final productName = rawMaterial['name'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return productName.contains(query);
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
                      labelText: 'Buscar Insumo',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredRawMaterials.length,
                    itemBuilder: (context, index) {
                      final rawMateral = filteredRawMaterials[index];
                      return Card(
                        color: AppPallete.gradient2,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      12.0), // Radio de los bordes redondeados
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        'assets/Ejemplo.png'), // Ruta de la imagen
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                width: 80,
                                height: 80,
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(rawMateral['name']),
                                subtitle: Text(
                                  'Stock: ${rawMateral['stock_quantity']}',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
