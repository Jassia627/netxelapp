// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/main.dart';

class ProductStock extends StatefulWidget {
  const ProductStock({super.key});

  @override
  _ProductStockState createState() => _ProductStockState();
}

class _ProductStockState extends State<ProductStock> {
  List<Map<String, dynamic>> _productos = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductos();
  }

  Future<void> _fetchProductos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase
          .from('products')
          .select(
              '*, products_categories(category_name), units_of_measures(large_name, short_name)')
          .eq('active', true)
          .order('name');

      setState(() {
        _productos = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProductos = _productos.where((producto) {
      final productName = producto['name'].toString().toLowerCase();
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
                      labelText: 'Buscar producto',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredProductos.length,
                    itemBuilder: (context, index) {
                      final producto = filteredProductos[index];
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
                                title: Text(producto['name'] +
                                    ' x ${producto['presentation_quantity']}${producto['units_of_measures']['short_name']}'),
                                subtitle: Text(
                                  'Stock: ${producto['stock_quantity']}',
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
