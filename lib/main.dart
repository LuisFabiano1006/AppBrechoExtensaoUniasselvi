import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/catalog/presentation/home_page.dart';

void main() async {
  // Garantir a inicialização dos bindings do Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Quando configurar as credenciais do Firebase no console, descomente a linha abaixo:
  // await Firebase.initializeApp();
  
  runApp(const BrechoSustentavelApp());
}

class BrechoSustentavelApp extends StatelessWidget {
  const BrechoSustentavelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brechó Sustentável',
      debugShowCheckedModeBanner: true,
      
      // Injeção do Tema Customizado em conformidade com o MD3
      theme: AppTheme.lightTheme,
      
      // Definição da rota inicial do App
      home: const HomePage(),
    );
  }
}
