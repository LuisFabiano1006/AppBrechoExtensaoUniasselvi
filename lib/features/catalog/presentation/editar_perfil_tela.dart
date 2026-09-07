import 'package:app_brecho/core/form/decoracao_campo_autenticacao.dart';
import 'package:app_brecho/core/snackbar/mostrar_snackbar.dart';
import 'package:app_brecho/features/auth/services/autenticacao_servico.dart';
import 'package:flutter/material.dart';

class EditarPerfilTela extends StatefulWidget {
  const EditarPerfilTela({super.key});

  @override
  State<EditarPerfilTela> createState() => _EditarPerfilTelaState();
}

class _EditarPerfilTelaState extends State<EditarPerfilTela> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();

  final _autenticacaoServico = AutenticacaoServico();
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    final usuario = _autenticacaoServico.usuarioAtual;
    if (usuario != null) {
      _nomeController.text = usuario.displayName ?? '';
      _emailController.text = usuario.email ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    final erro = await _autenticacaoServico.atualizarPerfilUsuario(
      nome: _nomeController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _carregando = false);

    if (erro != null) {
      mostrarSnackBar(context, texto: erro, isErro: true);
    } else {
      mostrarSnackBar(context, texto: 'Perfil atualizado com sucesso!', isErro: false);
      Navigator.of(context).pop(true);
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
        appBar: AppBar(
          title: const Text('Editar Perfil'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nomeController,
                  decoration: obterDecoracaoCampoAutenticacao(
                    dica: 'Nome de exibição',
                    icone: Icons.person_outline,
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) return 'Informe seu nome';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  enabled: false,
                  decoration: obterDecoracaoCampoAutenticacao(
                    dica: 'E-mail (não editável)',
                    icone: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 32),
                _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : FilledButton(
                        onPressed: _salvarPerfil,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Salvar Alterações', style: TextStyle(fontSize: 16)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
