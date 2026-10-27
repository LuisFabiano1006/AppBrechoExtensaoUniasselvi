import 'package:flutter/material.dart';
import 'package:app_brecho/core/snackbar/mostrar_snackbar.dart';
import 'package:app_brecho/features/catalog/presentation/editar_perfil_tela.dart';
import 'package:app_brecho/features/catalog/presentation/detalhes_produto_tela.dart';
import 'package:app_brecho/features/catalog/domain/produto_modelo.dart';
import 'package:app_brecho/features/catalog/services/produto_servico.dart';
import 'package:app_brecho/features/auth/services/autenticacao_servico.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _autenticacaoServico = AutenticacaoServico();
  final _produtoServico = ProdutoServico();
  
  // Estado para os filtros
  String? _categoriaSelecionada;
  String _termoBusca = '';
  final _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  /// Função auxiliar compacta para remover acentos usando Regular Expressions
  String _removerAcentos(String texto) {
    var resultado = texto.toLowerCase();
    resultado = resultado.replaceAll(RegExp(r'[àáâãäå]'), 'a');
    resultado = resultado.replaceAll(RegExp(r'[èéêë]'), 'e');
    resultado = resultado.replaceAll(RegExp(r'[ìíîï]'), 'i');
    resultado = resultado.replaceAll(RegExp(r'[òóôõö]'), 'o');
    resultado = resultado.replaceAll(RegExp(r'[ùúûü]'), 'u');
    resultado = resultado.replaceAll(RegExp(r'[ç]'), 'c');
    resultado = resultado.replaceAll(RegExp(r'[ñ]'), 'n');
    return resultado;
  }

  Future<void> _carregarDadosUsuario() async {
    final usuario = _autenticacaoServico.usuarioAtual;
    if (usuario != null) {
      await usuario.reload();
      if (mounted) setState(() {});

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

    final categorias = [
      'Casacos',
      'Calçados',
      'Acessórios',
      'Camisas',
      'Calças',
    ];

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
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();
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
          // BARRA DE PESQUISA POR TEXTO INSENSÍVEL A ACENTOS E CAIXA
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _buscaController,
              onChanged: (val) {
                setState(() {
                  _termoBusca = _removerAcentos(val.trim());
                });
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar peças, tamanhos, valores...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _termoBusca.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _buscaController.clear();
                            _termoBusca = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainer,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filtro por Categoria (FilterChip MD3)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categorias.map((cat) {
                  final isSelected = _categoriaSelecionada == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      onSelected: (selected) {
                        setState(() {
                          _categoriaSelecionada = selected ? cat : null;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              'Roupas e Acessórios Recentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Lista de Produtos com Filtro Insensível a Acentos e Caixa Alta/Baixa
          Expanded(
            child: StreamBuilder<List<ProdutoModelo>>(
              stream: _produtoServico.obterProdutosStream(
                categoriaFiltro: _categoriaSelecionada,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar desapegos: ${snapshot.error}',
                    ),
                  );
                }

                final todosProdutos = snapshot.data ?? [];

                // FILTRAGEM TOLERANTE A ACENTOS E CAIXA ALTA/BAIXA
                final produtos = todosProdutos.where((p) {
                  if (_termoBusca.isEmpty) return true;

                  final nome = _removerAcentos(p.nome);
                  final descricao = _removerAcentos(p.descricao);
                  final tamanho = _removerAcentos(p.tamanho);
                  final categoria = _removerAcentos(p.categoria);
                  final preco = p.preco.toString();

                  return nome.contains(_termoBusca) ||
                      descricao.contains(_termoBusca) ||
                      tamanho.contains(_termoBusca) ||
                      categoria.contains(_termoBusca) ||
                      preco.contains(_termoBusca);
                }).toList();

                if (produtos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum item encontrado para esta busca.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    final produto = produtos[index];
                    return Card(
                      color: theme.colorScheme.surfaceContainer,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetalhesProdutoTela(produto: produto),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 115,
                              width: double.infinity,
                              color: theme.colorScheme.secondary.withValues(
                                alpha: 0.15,
                              ),
                              child: produto.imagemUrl.isNotEmpty
                                  ? Image.network(
                                      produto.imagemUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Icon(
                                        Icons.checkroom,
                                        size: 40,
                                        color: theme.colorScheme.secondary,
                                      ),
                                    )
                                  : Icon(
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
                                    produto.nome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    produto.precoFormatado,
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
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Tam: ${produto.tamanho}',
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
                      ),
                    );
                  },
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
