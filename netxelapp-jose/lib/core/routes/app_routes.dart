import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/home.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';

  static Map<String, Widget Function(BuildContext)> routes = {
    login: (_) => const LoginPage(),
    signup: (_) => const SignupPage(),
    home: (_) => const Home(),
  };
}
