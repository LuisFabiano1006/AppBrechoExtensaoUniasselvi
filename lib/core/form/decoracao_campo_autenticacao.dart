import 'package:flutter/material.dart';

InputDecoration obterDecoracaoCampoAutenticacao({
  required String dica,
  required IconData icone,
}) {
  return InputDecoration(
    hintText: dica,
    prefixIcon: Icon(icone, color: const Color(0xFF8D6E63)), // Tom de terra / marrom
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    // Bordas de pílula arredondadas de 64pt para visual limpo e moderno (MD3)
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64),
      borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2), // Verde Folha
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64),
      borderSide: const BorderSide(color: Color(0xFFC62828), width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64),
      borderSide: const BorderSide(color: Color(0xFFC62828), width: 2.5),
    ),
  );
}
