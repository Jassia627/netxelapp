// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/features/home/pages/components/forms/proveedor_form.dart';
import 'package:netxelapp/main.dart';

class ProviderList extends StatefulWidget {
  const ProviderList({super.key});

  @override
  _ProviderListState createState() => _ProviderListState();
}

class _ProviderListState extends State<ProviderList> {
  final _client = supabase;
  List<Map<String, dynamic>> _providers = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await _client
            .from('providers')
            .select('*')
            .eq('active', true)
            .order('name');

        setState(() {
          _providers = response;
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

  Future<void> _addProvider(String name, String phone) async {
    try {
      await supabase.from('providers').insert({
        'name': name,
        'phone': phone,
        'user_id': supabase.auth.currentUser?.id,
      });
      _fetchProviders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      // Manejar error
    }
  }

  Future<void> _updateProvider(int index, String name, String phone) async {
    try {
      final providerId = _providers[index]['id'];
      await _client.from('providers').update({
        'name': name,
        'phone': phone,
        'user_id': supabase.auth.currentUser?.id,
      }).eq('id', providerId);
      _fetchProviders();
    } catch (e) {
      // Manejar error
    }
  }

  Future<void> _deleteProvider(int index) async {
    try {
      final providerId = _providers[index]['id'];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Eliminar proveedor'),
            content: Text(
                '¿Estás seguro de eliminar al proveedor "${_providers[index]['name']}"?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  await _client
                      .from('providers')
                      .update({'active': false}).eq('id', providerId);
                  Navigator.of(context).pop();
                  _fetchProviders();
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
    final filteredProviders = _providers.where((provider) {
      final providerName = provider['name'].toLowerCase();
      final query = _searchQuery.toLowerCase();
      return providerName.contains(query);
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
                      labelText: 'Buscar proveedor',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredProviders.length,
                    itemBuilder: (context, index) {
                      final provider = filteredProviders[index];
                      return Card(
                        color: AppPallete.gradient2,
                        child: ListTile(
                          title: Text(provider['name']),
                          subtitle: Text('Teléfono: ${provider['phone']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ProviderForm(
                                      provider: provider,
                                      onProviderUpdated: (name, phone) =>
                                          _updateProvider(index, name, phone),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteProvider(index),
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
                        builder: (context) => ProviderForm(
                          onProviderAdded: _addProvider,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.gradient2),
                    child: const Text('Agregar Proveedor'),
                  ),
                ),
              ],
            ),
    );
  }
}
