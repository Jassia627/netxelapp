import 'package:flutter/material.dart';
import 'package:netxelapp/features/home/drawer.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            appName), // Esto debería hacer que el botón del drawer aparezca
      ),
      drawer: const AppDrawer(),
      body: child,
    );
  }
}
