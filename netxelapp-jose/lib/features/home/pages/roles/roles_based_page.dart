// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:netxelapp/main.dart';

class RoleBasedPage extends StatefulWidget {
  final List<String> allowedRoles;
  final Widget child;

  const RoleBasedPage({
    super.key,
    required this.allowedRoles,
    required this.child,
  });

  @override
  _RoleBasedPageState createState() => _RoleBasedPageState();
}

class _RoleBasedPageState extends State<RoleBasedPage> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('profiles')
            .select('roles')
            .eq('id', user.id)
            .single();
        setState(() {
          userRole = response['roles'] as String?;
        });
      }
    } catch (e) {
      //print('Error al obtener el rol del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!widget.allowedRoles.contains(userRole)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso Denegado'),
        ),
        body: const Center(
          child: Text('No tienes permiso para acceder a esta página.'),
        ),
      );
    }

    return widget.child;
  }
}
