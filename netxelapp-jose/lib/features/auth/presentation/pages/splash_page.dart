// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:netxelapp/core/utils/show_snackbar.dart';
import 'package:netxelapp/features/data/user_functions.dart';
import 'package:netxelapp/main.dart';
import 'package:postgrest/postgrest.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirect();
    });
  }

  Future<void> _redirect() async {
    try {
      final session = supabase.auth.currentSession;
      if (session != null) {
        username = await getUserNameByID(session.user.id);
        if (!mounted) return; // Mover esta línea aquí

        final factories = await supabase
            .from('factories')
            .select()
            .eq('user_id', session.user.id);

        if (!mounted) return; // Agregar otra verificación de mounted

        if (factories.isNotEmpty) {
          context.go('/home');
        } else {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/add_fabrica', (route) => false);
          print(factories);
        }
      } else {
        context.go('/login');
      }
    } on PostgrestException catch (e) {
      if (mounted) showSnackBar(context, e.message);
    } catch (e) {
      if (mounted) showSnackBar(context, 'Error: $e');
      print('as');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
