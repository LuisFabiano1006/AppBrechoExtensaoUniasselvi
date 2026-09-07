import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/roteador_tela.dart';

void main() async {
  // Garante que as bindings do Flutter estejam inicializadas antes de rodar código assíncrono
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização assíncrona do Firebase
  await Firebase.initializeApp();

  runApp(const BrechoSustentavelApp());
}

class BrechoSustentavelApp extends StatelessWidget {
  const BrechoSustentavelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brechó Sustentável',
      debugShowCheckedModeBanner: true,
      theme: AppTheme.lightTheme, // Tema MD3 customizado
      home: const RoteadorTela(), // O roteador gerencia qual tela exibir inicialmente
    );
  }
}
