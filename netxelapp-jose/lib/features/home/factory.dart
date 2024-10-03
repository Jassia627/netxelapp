// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:netxelapp/main.dart';

class NuevaFabricaPage extends StatefulWidget {
  const NuevaFabricaPage({super.key});

  @override
  _NuevaFabricaPageState createState() => _NuevaFabricaPageState();
}

class _NuevaFabricaPageState extends State<NuevaFabricaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreFabricaController = TextEditingController();

  @override
  void dispose() {
    _nombreFabricaController.dispose();
    super.dispose();
  }

  Future<void> _crearFabrica() async {
    if (_formKey.currentState!.validate()) {
      final nombreFabrica = _nombreFabricaController.text;
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        try {
          await supabase.from('factories').insert({
            'name': nombreFabrica,
            'user_id': userId,
          });
          // Aquí puedes realizar acciones adicionales después de crear la fábrica
          Navigator.of(context).pushReplacementNamed('/home');
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay una sesión de usuario válida.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Fábrica'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Crear Nueva Fábrica'),
                  content: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _nombreFabricaController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Fábrica',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre para la fábrica';
                        }
                        return null;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: _crearFabrica,
                      child: const Text('Crear'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text('Crear Nueva Fábrica'),
        ),
      ),
    );
  }
}
