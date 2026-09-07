import 'package:app_brecho/core/snackbar/mostrar_snackbar.dart';
import 'package:app_brecho/features/catalog/presentation/editar_perfil_tela.dart';
import 'package:app_brecho/features/auth/services/autenticacao_servico.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _desapegosExemplo = [
    {
      'titulo': 'Jaqueta Jeans Vintage',
      'preco': 'R\$ 79,90',
      'tamanho': 'G',
      'estado': 'Excelente',
    },
    {
      'titulo': 'Bolsa de Couro Marrom',
      'preco': 'R\$ 45,00',
      'tamanho': 'Único',
      'estado': 'Bom',
    },
    {
      'titulo': 'Ténis Casual Verde',
      'preco': 'R\$ 120,00',
      'tamanho': '38',
      'estado': 'Novo',
    },
    {
      'titulo': 'Camisa de Linho Branca',
      'preco': 'R\$ 55,00',
      'tamanho': 'M',
      'estado': 'Excelente',
    },
  ];

  final _autenticacaoServico = AutenticacaoServico();

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final usuario = _autenticacaoServico.usuarioAtual;
    if (usuario != null) {
      // Recarrega imediatamente
      await usuario.reload();
      if (mounted) setState(() {});

      // Se por latência da rede o nome ainda estiver vazio, faz uma nova checagem após 800ms
      if (usuario.displayName == null || usuario.displayName!.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 800));
        await _autenticacaoServico.usuarioAtual?.reload();
        if (mounted) setState(() {});
      }
    }
  }

  Future<void> _confirmarExclusaoConta(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Excluir Conta?'),
          content: const Text(
            'Esta ação apagará permanentemente sua conta e seus dados do sistema. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Excluir Definitivamente'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      final erro = await _autenticacaoServico.excluirContaUsuario();

      if (!context.mounted) return;

      if (erro != null) {
        mostrarSnackBar(context, texto: erro, isErro: true);
      } else {
        mostrarSnackBar(
          context,
          texto: 'Sua conta foi excluída com sucesso.',
          isErro: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usuario = _autenticacaoServico.usuarioAtual;
    final nomeUsuario = (usuario?.displayName?.isNotEmpty ?? false)
        ? usuario!.displayName!
        : 'Minha Conta';
    final fotoUrl = usuario?.photoURL;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Brechó Comunitário')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white24,
                    backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                        ? NetworkImage(fotoUrl)
                        : null,
                    child: (fotoUrl == null || fotoUrl.isEmpty)
                        ? const Icon(
                            Icons.account_circle,
                            size: 56,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nomeUsuario,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Botão "Editar perfil" estilizado dentro do tema
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        Navigator.of(context);
                        final atualizou = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditarPerfilTela(),
                          ),
                        );
                        if (atualizou == true) {
                          setState(() {});
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Editar perfil",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sair da conta"),
              onTap: () {
                _autenticacaoServico.deslogarUsuario();
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.delete_forever,
                color: theme.colorScheme.error,
              ),
              title: Text(
                "Excluir minha conta",
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _confirmarExclusaoConta(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Casacos'),
                    onSelected: (val) {},
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Calçado'),
                    onSelected: (val) {},
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Tamanho M'),
                    onSelected: (val) {},
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Acessórios'),
                    onSelected: (val) {},
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Roupas e Acessórios Recentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.82,
              ),
              itemCount: _desapegosExemplo.length,
              itemBuilder: (context, index) {
                final produto = _desapegosExemplo[index];
                return Card(
                  color: theme.colorScheme.surfaceContainer,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 115,
                        width: double.infinity,
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 0.15,
                        ),
                        child: Icon(
                          Icons.checkroom,
                          size: 40,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produto['titulo'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              produto['preco'],
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Tam: ${produto['tamanho']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Desapegar'),
        icon: const Icon(Icons.add_photo_alternate_outlined),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}
