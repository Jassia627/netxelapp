// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/features/home/pages/components/forms/categoria_form.dart';
import 'package:netxelapp/main.dart';

class CategoriaList extends StatefulWidget {
  const CategoriaList({super.key});

  @override
  _CategoriaListState createState() => _CategoriaListState();
}

class _CategoriaListState extends State<CategoriaList> {
  final _client = supabase;
  List<Map<String, dynamic>> _categorias = [];
  String _searchQuery = '';
  bool _isLoading = true;
  int? factoryId;

  @override
  void initState() {
    super.initState();
    _fetchCategorias();
  }

  Future<void> _fetchCategorias() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final factories = await supabase
            .from('factories')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();

        if (factories != null) {
          final factoryId = factories['id'];
          final response = await _client
              .from('products_categories')
              .select('*')
              .eq('active', true)
              .eq('factory_id', factoryId)
              .order('category_name');

          setState(() {
            _categorias = response;
            _isLoading = false;
          });
        } else {
          // Manejar caso cuando el usuario no tiene una fábrica asociada
          setState(() {
            _isLoading = false;
          });
        }
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

  Future<int?> _getUserFactoryId() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final factories = await supabase
            .from('factories')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();

        if (factories != null) {
          return factories['id'];
        }
      }
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return null;
    }
  }

  Future<void> _addCategoria(String nombre) async {
    try {
      final factoryId = await _getUserFactoryId();
      if (factoryId != null) {
        await supabase.from('products_categories').insert({
          'category_name': nombre,
          'user_id': supabase.auth.currentUser?.id,
          'factory_id': factoryId,
        });
        _fetchCategorias();
      } else {
        // Manejar error de fábrica no encontrada
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      // Manejar error
    }
  }

  Future<void> _updateCategoria(int index, String nombre) async {
    try {
      final categoriaId = _categorias[index]['id'];
      await _client.from('products_categories').update({
        'category_name': nombre,
        'user_id': supabase.auth.currentUser?.id,
      }).eq('id', categoriaId);
      _fetchCategorias();
    } catch (e) {
      // Manejar error
    }
  }

  Future<void> _deleteCategoria(int index) async {
    try {
      final categoriaId = _categorias[index]['id'];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Eliminar categoría'),
            content: Text(
                '¿Estás seguro de eliminar la categoría "${_categorias[index]['category_name']}"?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  await _client.from('products_categories').update({
                    'active': false,
                  }).eq('id', categoriaId);
                  Navigator.of(context).pop();
                  _fetchCategorias();
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
    final filteredCategorias = _categorias.where((categoria) {
      final categoryName = categoria['category_name'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return categoryName.contains(query);
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
                      labelText: 'Buscar categoría',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredCategorias.length,
                    itemBuilder: (context, index) {
                      final categoria = filteredCategorias[index];
                      return Card(
                        color: AppPallete.gradient2,
                        child: ListTile(
                          title: Text(categoria['category_name']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => CategoriaForm(
                                      categoria: categoria['category_name'],
                                      onCategoriaAgregada: (updatedCategoria) =>
                                          _updateCategoria(
                                              index, updatedCategoria),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteCategoria(index),
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
                        builder: (context) => CategoriaForm(
                          onCategoriaAgregada: _addCategoria,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.gradient2),
                    child: const Text('Agregar Categoría'),
                  ),
                ),
              ],
            ),
    );
  }
}
