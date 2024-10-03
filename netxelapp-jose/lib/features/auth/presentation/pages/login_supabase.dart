// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:netxelapp/core/common/widgets/loader.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/core/utils/show_snackbar.dart';
import 'package:netxelapp/features/auth/presentation/pages/signup_page.dart';
import 'package:netxelapp/features/auth/presentation/widgets/auth_field.dart';
import 'package:netxelapp/features/data/user_functions.dart';
import 'package:netxelapp/main.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LoginPageSupabase extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const LoginPageSupabase());
  const LoginPageSupabase({super.key});

  @override
  State<LoginPageSupabase> createState() => _LoginPageSupabaseState();
}

class _LoginPageSupabaseState extends State<LoginPageSupabase> {
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
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
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
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/NetxelLogo.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: SupaEmailAuth(
              redirectTo: kIsWeb ? null : 'io.mydomain.myapp://callback',
              onSignInComplete: (response) async {
                await login();
              },
              onSignUpComplete: (response) {},
              metadataFields: [
                MetaDataField(
                  prefixIcon: const Icon(Icons.person),
                  label: 'Correo',
                  key: 'correo',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Ingresa algo...';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/LoginLink', (route) => false);
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

  Stack signupButton() {
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
