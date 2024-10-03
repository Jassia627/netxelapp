import 'package:flutter/material.dart';

class AuthField extends StatefulWidget {
  final String hintText;
  final TextStyle? style;
  final TextEditingController controller;
  final bool isObscuretext;

  const AuthField({
    super.key,
    required this.hintText,
    this.style,
    required this.controller,
    this.isObscuretext = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuthFieldState createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: widget.isObscuretext
            ? Padding(
                padding: const EdgeInsets.only(
                    right: 20), // Ajusta este valor según lo que necesites
                child: IconButton(
                  icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              )
            : null,
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "${widget.hintText} is missing";
        }
        return null;
      },
      obscureText: widget.isObscuretext ? _obscureText : false,
      controller: widget.controller,
      style: widget.style,
    );
  }
}
