// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:netxelapp/features/data/user_functions.dart';
import 'package:netxelapp/main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _username = 'Cargando...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final session = supabase.auth.currentSession;
      if (session != null) {
        final name = await getUserNameByID(session.user.id);
        setState(() {
          _username = name;
          _isLoading = false;
        });
      } else {
        setState(() {
          _username = 'No hay sesión';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _username = 'Error al cargar';
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/NetxelLogo.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),
                Text('Bienvenido, $_username'),
              ],
            ),
    );
  }
}
