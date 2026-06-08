import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32),     // Verde Folha Principal
        primary: const Color(0xFF2E7D32),
        secondary: const Color(0xFF8D6E63),   // Tom de Terra / Marrom Claro
        
        // CORREÇÃO: Substituído 'background' por 'surface' e 'surfaceContainer'
        surface: const Color(0xFFF9FBE7),     // Antigo background (Off-white esverdeado)
        surfaceContainer: Colors.white,       // Superfície dos cards e containers internos
        
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        // CORREÇÃO: Alterado .withOpacity() para .withValues(alpha: ...)
        selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
        side: const BorderSide(color: Color(0xFF8D6E63), width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
