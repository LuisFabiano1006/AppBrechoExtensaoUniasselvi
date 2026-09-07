import 'package:flutter/material.dart';
import 'package:app_brecho/features/auth/services/autenticacao_servico.dart';
import 'package:app_brecho/core/snackbar/mostrar_snackbar.dart';
import 'package:app_brecho/core/form/decoracao_campo_autenticacao.dart';

class RedefinirSenhaTela extends StatefulWidget {
  const RedefinirSenhaTela({super.key});

  @override
  State<RedefinirSenhaTela> createState() => _RedefinirSenhaTelaState();
}

class _RedefinirSenhaTelaState extends State<RedefinirSenhaTela> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _autenticacaoServico = AutenticacaoServico();
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O e-mail não pode ser vazio';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(valor)) {
      return 'O e-mail inserido não é válido';
    }
    return null;
  }

  Future<void> _enviarEmailRedefinicao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
    });

    final email = _emailController.text.trim();
    String? resultadoErro;

    try {
      resultadoErro = await _autenticacaoServico.redefinirSenha(email);
    } catch (e) {
      resultadoErro = 'Erro inesperado: $e';
    }

    if (!mounted) return;

    setState(() {
      _carregando = false;
    });

    if (resultadoErro != null) {
      mostrarSnackBar(context, texto: resultadoErro, isErro: true);
    } else {
      mostrarSnackBar(
        context,
        texto: 'Link enviado para $email. Verifique sua caixa de entrada!',
        isErro: false,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Redefinir Senha'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recuperação de Acesso',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Informe o e-mail cadastrado abaixo para receber o link de redefinição de senha.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  
                  // Texto informativo sobre verificar a caixa de Spam
                  Text(
                    'Caso não encontre o e-mail em alguns minutos, verifique sua caixa de Spam ou Lixo Eletrônico.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: obterDecoracaoCampoAutenticacao(
                      dica: 'Endereço de E-mail',
                      icone: Icons.email_outlined,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validarEmail,
                  ),
                  const SizedBox(height: 24),
                  _carregando
                      ? const Center(child: CircularProgressIndicator())
                      : FilledButton(
                          onPressed: _enviarEmailRedefinicao,
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(64),
                            ),
                          ),
                          child: const Text(
                            'Enviar E-mail de Recuperação',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
