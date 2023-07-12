import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final void Function() validation;
  final Icon? icon;
  final bool? obscurePassword;
  final IconButton? iconButton;
  final bool? readOnly;
  final TextInputType? textInputType;

  const CustomTextField({super.key,
    required this.label,
    required this.controller,
    required this.validation,
    this.icon,
    this.obscurePassword,
    this.iconButton,
    this.readOnly,
    this.textInputType
  });

  @override
  State<StatefulWidget> createState() =>  _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    widget.validation();

  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: widget.readOnly??false ,
      controller: widget.controller,
      obscureText: widget.obscurePassword??false,
      style: const TextStyle(color: Colors.grey),
      keyboardType:widget.textInputType,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: widget.icon,
        suffixIcon: widget.iconButton
      ),
    );
  }
}