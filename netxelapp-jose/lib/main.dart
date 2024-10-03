import 'package:flutter/material.dart';
import 'package:netxelapp/core/secrets/app_secrets.dart';
import 'package:netxelapp/core/theme/theme.dart';
import 'package:netxelapp/features/home/router_configuration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnnonKey,
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig:
          goRouter, // Usa el goRouter definido en router_configuration.dart
      title: 'Netxel',
      theme: AppTheme.darkThemeMode.copyWith(
        textTheme: AppTheme.darkThemeMode.textTheme.apply(
          fontFamily: 'Poppins',
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
