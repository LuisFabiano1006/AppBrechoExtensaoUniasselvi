import 'package:flutter/material.dart';
import 'package:app_brecho/features/auth/services/autenticacao_servico.dart';
import 'package:app_brecho/core/snackbar/mostrar_snackbar.dart';
import 'package:app_brecho/core/form/decoracao_campo_autenticacao.dart';
import 'redefinir_senha_tela.dart';

class AutenticacaoTela extends StatefulWidget {
  const AutenticacaoTela({super.key});

  @override
  State<AutenticacaoTela> createState() => _AutenticacaoTelaState();
}

class _AutenticacaoTelaState extends State<AutenticacaoTela> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para captação limpa de dados
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final _autenticacaoServico = AutenticacaoServico();

  // Estados reativos da tela
  bool _queroEntrar = true;
  bool _carregando = false;

  // Estados para visibilidade das senhas
  bool _ocultarSenha = true;
  bool _ocultarConfirmarSenha = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  // Heurística #5: Validador de E-mail usando RegExp robusto local
  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O e-mail não pode ser vazio';
    }
    if (valor.length < 5) {
      return 'O e-mail é muito curto';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(valor)) {
      return 'O e-mail inserido não é válido';
    }
    return null;
  }

  // Validador de Senha (requisito mínimo nativo do Firebase: 6 caracteres)
  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'A senha não pode ser vazia';
    }
    if (valor.length < 6) {
      return 'A senha deve conter pelo menos 6 caracteres';
    }
    return null;
  }

  // Validador de Confirmação de Senha (executado localmente para evitar erros de rede)
  String? _validarConfirmarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Confirme a sua senha';
    }
    if (valor != _senhaController.text) {
      return 'As senhas digitadas não coincidem';
    }
    return null;
  }

  // Validador do campo Nome do usuário
  String? _validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O nome não pode ser vazio';
    }
    if (valor.trim().length < 3) {
      return 'O nome digitado é muito curto';
    }
    return null;
  }

  // Método de Submissão de Formulário (Login / Cadastro)
  Future<void> _submeterFormulario() async {
    // 1. Validação local do formulário antes de enviar requisições assíncronas
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
    });

    String? resultadoErro;

    try {
      if (_queroEntrar) {
        // FLUXO DE LOGIN
        resultadoErro = await _autenticacaoServico.logarUsuario(
          email: _emailController.text.trim(),
          senha: _senhaController.text,
        );
      } else {
        // FLUXO DE CADASTRO
        resultadoErro = await _autenticacaoServico.cadastrarUsuario(
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          senha: _senhaController.text,
        );
      }
    } catch (e) {
      resultadoErro = 'Erro de execução inesperado: $e';
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
        texto: _queroEntrar ? 'Login realizado com sucesso!' : 'Cadastro realizado com sucesso!',
        isErro: false,
      );
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
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícone Identitário do Brechó (Estilo MD3)
                  Icon(
                    Icons.store_mall_directory_outlined,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Brechó Sustentável',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
      
                  // Campo Nome: Visibilidade condicional em Dart (Apenas no Cadastro)
                  if (!_queroEntrar) ...[
                    TextFormField(
                      controller: _nomeController,
                      decoration: obterDecoracaoCampoAutenticacao(
                        dica: 'Nome',
                        icone: Icons.person_outline,
                      ),
                      keyboardType: TextInputType.name,
                      validator: _validarNome,
                    ),
                    const SizedBox(height: 16),
                  ],
      
                  // Campo E-mail: Sempre visível
                  TextFormField(
                    controller: _emailController,
                    decoration: obterDecoracaoCampoAutenticacao(
                      dica: 'Endereço de E-mail',
                      icone: Icons.email_outlined,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validarEmail,
                  ),
                  const SizedBox(height: 16),
      
                  // Campo Senha: Sempre visível
                  TextFormField(
                    controller: _senhaController,
                    obscureText: _ocultarSenha,
                    decoration: obterDecoracaoCampoAutenticacao(
                      dica: 'Senha de Acesso',
                      icone: Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarSenha ? Icons.visibility : Icons.visibility_off,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _ocultarSenha = !_ocultarSenha;
                          });
                        },
                      ),
                    ),
                    validator: _validarSenha,
                  ),
                  const SizedBox(height: 16),
      
                  // Campo Confirmar Senha: Visibilidade condicional (Apenas no Cadastro)
                  if (!_queroEntrar) ...[
                    TextFormField(
                      controller: _confirmarSenhaController,
                      obscureText: _ocultarConfirmarSenha,
                      decoration: obterDecoracaoCampoAutenticacao(
                        dica: 'Confirme sua Senha',
                        icone: Icons.lock_clock_outlined,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarConfirmarSenha ? Icons.visibility : Icons.visibility_off,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _ocultarConfirmarSenha = !_ocultarConfirmarSenha;
                            });
                          },
                        ),
                      ),
                      validator: _validarConfirmarSenha,
                    ),
                    const SizedBox(height: 24),
                  ],
      
                  // Botão "Esqueci minha senha" (Exibido apenas no modo de login)
                  if (_queroEntrar)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: TextButton(
                          onPressed: _carregando
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RedefinirSenhaTela(),
                                    ),
                                  );
                                },
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.secondary,
                          ),
                          child: const Text('Esqueci minha senha'),
                        ),
                      ),
                    ),
      
                  // Botão de Envio de Dados Dinâmico (Carregamento / Ação)
                  _carregando
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : FilledButton(
                          onPressed: _submeterFormulario,
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(64),
                            ),
                          ),
                          child: Text(
                            _queroEntrar ? 'Entrar' : 'Criar Conta',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                  const SizedBox(height: 16),
      
                  // Alternância Dinâmica entre os Modos (Heurística #8: Minimalismo e Foco)
                  TextButton(
                    onPressed: _carregando
                        ? null
                        : () {
                            setState(() {
                              _queroEntrar = !_queroEntrar;
                              _formKey.currentState?.reset(); // Reseta os avisos de erro visuais
                            });
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    child: Text(
                      _queroEntrar
                          ? 'Não possui uma conta? Cadastre-se'
                          : 'Já possui uma conta? Faça Login',
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
