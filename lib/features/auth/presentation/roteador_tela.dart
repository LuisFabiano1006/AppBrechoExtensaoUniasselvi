import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_brecho/features/catalog/presentation/home_page.dart';
import 'autenticacao_tela.dart';

class RoteadorTela extends StatelessWidget {
  const RoteadorTela({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se a conexão estiver ativa e houver dados de usuário, vai para a Home
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData && snapshot.data != null) {
            return const HomePage();
          }
          // Caso contrário, direciona para o formulário de login/cadastro
          return const AutenticacaoTela();
        }

        // Estado temporário de carregamento enquanto o stream conecta
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
