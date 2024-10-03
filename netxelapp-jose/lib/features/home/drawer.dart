// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/features/data/user_functions.dart';
import 'package:netxelapp/main.dart';

String appName = '';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<String> _userRoles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRoles();
  }

  Future<void> _loadUserRoles() async {
    if (_userRoles.isEmpty) {
      final roles = await _getUserRoles();
      if (mounted) {
        setState(() {
          _userRoles = roles;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<String>> _getUserRoles() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('profiles')
            .select('roles')
            .eq('id', user.id)
            .single();
        final rolesString = response['roles'] as String?;
        if (rolesString != null) {
          return rolesString.split(',').map((e) => e.trim()).toList();
        }
      }
    } catch (e) {
      print('Error al obtener los roles del usuario: $e');
    }
    return [];
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      print('Error al cerrar sesión: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  List<Widget> _buildDrawerItems(List<String> roles) {
    final List<Widget> items = [
      UserAccountsDrawerHeader(
        decoration: const BoxDecoration(
          color: AppPallete.gradient2,
        ),
        accountName: Text(
          username,
          style: const TextStyle(fontSize: 18.0),
        ),
        accountEmail: Text(
          supabase.auth.currentUser?.email ?? 'Correo no disponible',
          style: const TextStyle(fontSize: 14.0),
        ),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            username.isNotEmpty ? username[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 40.0,
              color: AppPallete.gradient2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      const Divider(),
      ListTile(
        title: const Text('Inicio'),
        leading: const Icon(Icons.home),
        onTap: () {
          Navigator.pop(context);
          context.go('/home');
        },
      ),
      const Divider(),
    ];

    bool hasAnyRole(List<String> requiredRoles) {
      return roles.any((role) => requiredRoles.contains(role));
    }

    if (hasAnyRole(['admin', 'manager', 'registro'])) {
      items.add(
        ExpansionTile(
          title: const Text('Registros'),
          leading: const Icon(Icons.factory),
          children: [
            ListTile(
                title: const Text('Registro de Categorías'),
                leading: const Icon(Icons.category),
                onTap: () {
                  appName = 'Categorias';
                  Navigator.pop(context);
                  context.go('/categorias');
                }),
            ListTile(
              title: const Text('Registro de Medidas'),
              leading: const Icon(Icons.straighten),
              onTap: () {
                appName = 'Medidas';
                Navigator.pop(context);
                context.go('/medidas');
              },
            ),
            ListTile(
              title: const Text('Registro de Empleados'),
              leading: const Icon(Icons.people_outline),
              onTap: () {
                appName = 'Empleados';
                Navigator.pop(context);
                context.go('/empleados');
              },
            ),
            ListTile(
              title: const Text('Registro de Insumos'),
              leading: const Icon(Icons.inventory),
              onTap: () {
                appName = 'Insumos';
                Navigator.pop(context);
                context.go('/insumos');
              },
            ),
            ListTile(
              title: const Text('Registro de Productos'),
              leading: const Icon(Icons.production_quantity_limits),
              onTap: () {
                appName = 'Productos';
                Navigator.pop(context);
                context.go('/productos');
              },
            ),
            ListTile(
              title: const Text('Recetas de Producción'),
              leading: const Icon(Icons.menu_book),
              onTap: () {
                appName = 'Recetas de produccíon';
                Navigator.pop(context);
                context.go('/recipes');
              },
            ),
          ],
        ),
      );
    }

    if (hasAnyRole(['admin', 'manager'])) {
      items.add(
        ExpansionTile(
          title: const Text('Proveedores'),
          leading: const Icon(Icons.store),
          children: [
            ListTile(
              title: const Text('Registro de Proveedores'),
              leading: const Icon(Icons.add_business),
              onTap: () {
                appName = 'Proveedores';
                Navigator.pop(context);
                context.go('/proveedores');
              },
            ),
          ],
        ),
      );
    }

    if (hasAnyRole(['admin', 'manager', 'ventas'])) {
      items.add(
        ExpansionTile(
          title: const Text('Ventas'),
          leading: const Icon(Icons.point_of_sale),
          children: [
            ListTile(
              title: const Text('Registro de Ventas'),
              leading: const Icon(Icons.sell),
              onTap: () {
                appName = 'Nueva venta';
                Navigator.pop(context);
                context.go('/ventas');
              },
            ),
            ListTile(
              title: const Text('Historial de Ventas'),
              leading: const Icon(Icons.history),
              onTap: () {
                appName = 'Historial de ventas';
                Navigator.pop(context);
                context.go('/ventashistorial');
              },
            ),
          ],
        ),
      );
    }

    if (hasAnyRole(['admin', 'manager', 'inventario'])) {
      items.add(
        ExpansionTile(
          title: const Text('Stocks'),
          leading: const Icon(Icons.inventory_2),
          children: [
            ListTile(
              title: const Text('Productos'),
              leading: const Icon(Icons.shopify),
              onTap: () {
                appName = 'Stock de productos';
                Navigator.pop(context);
                context.go('/productstock');
              },
            ),
            ListTile(
              title: const Text('Insumos'),
              leading: const Icon(Icons.table_rows_sharp),
              onTap: () {
                appName = 'Stock de materia prima';
                Navigator.pop(context);
                context.go('/rawmaterials');
              },
            ),
          ],
        ),
      );
    }

    if (hasAnyRole(['admin', 'manager', 'compras'])) {
      items.add(
        ExpansionTile(
          title: const Text('Compras'),
          leading: const Icon(Icons.shopping_cart),
          children: [
            ListTile(
              title: const Text('Compra de insumos'),
              leading: const Icon(Icons.add_shopping_cart),
              onTap: () {
                appName = 'Compra de insumos';

                Navigator.pop(context);
                context.go('/comprainsumos');
              },
            ),
          ],
        ),
      );
    }
    if (hasAnyRole(['admin', 'manager', 'compras'])) {
      items.add(
        ExpansionTile(
          title: const Text('Producciones'),
          leading: const Icon(Icons.propane_tank_rounded),
          children: [
            ListTile(
              title: const Text('Nueva produccion'),
              leading: const Icon(Icons.add_shopping_cart),
              onTap: () {
                appName = 'Producciones';

                Navigator.pop(context);
                context.go('/production');
              },
            ),
          ],
        ),
      );
    }
    if (hasAnyRole(['admin', 'manager', 'compras'])) {
      items.add(
        ExpansionTile(
          title: const Text('Gastos'),
          leading: const Icon(Icons.propane_tank_rounded),
          children: [
            ListTile(
              title: const Text('Nuevo gasto'),
              leading: const Icon(Icons.add_shopping_cart),
              onTap: () {
                appName = 'Gastos';

                Navigator.pop(context);
                context.go('/expenses');
              },
            ),
            ListTile(
              title: const Text('Categorias'),
              leading: const Icon(Icons.add_shopping_cart),
              onTap: () {
                appName = 'Categorias';

                Navigator.pop(context);
                context.go('/expensesCategories');
              },
            ),
          ],
        ),
      );
    }

    items.addAll([
      const Divider(),
      ListTile(
        title: const Text('Cerrar sesión'),
        leading: const Icon(Icons.logout),
        onTap: _signOut,
      ),
    ]);

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: _buildDrawerItems(_userRoles),
            ),
    );
  }
}
