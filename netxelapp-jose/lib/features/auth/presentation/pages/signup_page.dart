import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:netxelapp/core/common/widgets/loader.dart';
import 'package:netxelapp/core/theme/app_palette.dart';
import 'package:netxelapp/core/utils/show_snackbar.dart';
import 'package:netxelapp/features/auth/presentation/widgets/auth_field.dart';
import 'package:netxelapp/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const SignupPage());
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false; // Variable de estado para el loader

  Future<void> signUp() async {
    setState(() {
      isLoading = true; // Muestra el loader
    });

    try {
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {'name': nameController.text.trim()},
      );
      if (!mounted) return;
      if (response.user != null) {
        context.go('/login');
      }
    } on AuthException catch (e) {
      showSnackBar(context, e.message);
    } finally {
      setState(() {
        isLoading = false; // Oculta el loader
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        body: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
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
                      nameField(),
                      const SizedBox(height: 15),
                      emailField(),
                      const SizedBox(height: 15),
                      passwordField(),
                      const SizedBox(height: 15),
                      signupButton(),
                      const SizedBox(height: 20),
                      loginTextButton(context),
                      const SizedBox(height: 20),
                      GestureDetector(
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            color: AppPallete.gradient3,
                                            fontWeight: FontWeight.bold))
                              ]),
                        ),
                      )
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
      'Registrarse.',
      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
    );
  }

  AuthField nameField() =>
      AuthField(hintText: 'Nombre', controller: nameController);

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
        context.go('/login');
      },
      child: RichText(
        text: TextSpan(
            text: '¿Ya tienes una cuenta?',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.normal),
            children: [
              TextSpan(
                  text: ' Iniciar sesión',
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
            signUp();
          },
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(400, 55),
            backgroundColor: AppPallete.gradient2,
          ),
          child: const Text(
            'Registrarse',
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
