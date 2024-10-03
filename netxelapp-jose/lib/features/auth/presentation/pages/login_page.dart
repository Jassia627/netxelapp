// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:netxelapp/core/common/widgets/loader.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/core/utils/show_snackbar.dart';
import 'package:netxelapp/features/auth/presentation/pages/signup_page.dart';
import 'package:netxelapp/features/auth/presentation/widgets/auth_field.dart';
import 'package:netxelapp/features/data/user_functions.dart';
import 'package:netxelapp/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const LoginPage());
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      if (!mounted) return;
      if (response.user != null) {
        final String userId = response.user!.id;
        await Future.delayed(Duration.zero);
        username = await getUserNameByID(userId);

        // Verificar si el usuario tiene una fábrica asociada
        final factories =
            await supabase.from('factories').select('id').eq('user_id', userId);

        if (factories.isNotEmpty) {
          context.go('/home');
        } else {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/add_fabrica', (route) => false);
        }
      }
    } on AuthException catch (e) {
      showSnackBar(context, e.message);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        body: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height *
                0.85, // Ajusta el valor según sea necesario
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      netxelLogo(),
                      const SizedBox(height: 30),
                      signupText(),
                      const SizedBox(height: 30),
                      emailField(),
                      const SizedBox(height: 15),
                      passwordField(),
                      const SizedBox(height: 15),
                      loginButton(),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      loginTextButton(context),
                      const SizedBox(height: 20),
                      loginLinkTextButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Image netxelLogo() {
    return Image.asset(
      'assets/NetxelLogo.png',
      width: 150,
      height: 150,
    );
  }

  Text signupText() {
    return const Text(
      'Iniciar sesión.',
      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
    );
  }

  AuthField emailField() => AuthField(
        hintText: 'Correo',
        controller: emailController,
      );

  AuthField passwordField() => AuthField(
        hintText: 'Contraseña',
        controller: passwordController,
        isObscuretext: true,
      );

  GestureDetector loginTextButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, SignupPage.route());
      },
      child: RichText(
        text: TextSpan(
            text: '¿No tienes una cuenta?',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.normal),
            children: [
              TextSpan(
                  text: ' Registrarse',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppPallete.gradient3, fontWeight: FontWeight.bold))
            ]),
      ),
    );
  }

  GestureDetector loginLinkTextButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/LoginLink');
      },
      child: RichText(
        text: TextSpan(
            text: 'Inicia sesion con un clic ',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.normal),
            children: [
              TextSpan(
                  text: ' Link magico',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppPallete.gradient3, fontWeight: FontWeight.bold))
            ]),
      ),
    );
  }

  Stack loginButton() {
    return Stack(
      children: [
        ElevatedButton(
          onPressed: () async {
            await login();
          },
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(400, 55),
            backgroundColor: AppPallete.gradient2,
          ),
          child: const Text(
            'Iniciar sesión',
            style: TextStyle(
              fontSize: 20,
              color: AppPallete.whiteColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (isLoading) const Loader(), // Muestra el loader si isLoading es true
      ],
    );
  }
}
