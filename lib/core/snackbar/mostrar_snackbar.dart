import 'package:flutter/material.dart';

void mostrarSnackBar(
  BuildContext context, {
  required String texto,
  bool isErro = true,
}) {
  // Cancela Snackbars anteriores para evitar sobreposição irritante (Heurística #3)
  ScaffoldMessenger.of(context).clearSnackBars();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      // Cores semânticas do Brechó (Vermelho Profundo para Erros / Verde Folha para Sucessos)
      backgroundColor: isErro ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      showCloseIcon: true,
    ),
  );
}
