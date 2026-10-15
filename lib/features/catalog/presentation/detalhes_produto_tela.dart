import 'package:flutter/material.dart';
import 'package:app_brecho/features/catalog/domain/produto_modelo.dart';
import 'package:app_brecho/features/catalog/services/produto_servico.dart';

/// Tela de Exibição de Detalhes do Produto utilizando Card do Material Design 3.
class DetalhesProdutoTela extends StatefulWidget {
  final ProdutoModelo produto;

  const DetalhesProdutoTela({
    super.key,
    required this.produto,
  });

  @override
  State<DetalhesProdutoTela> createState() => _DetalhesProdutoTelaState();
}

class _DetalhesProdutoTelaState extends State<DetalhesProdutoTela> {
  final ProdutoServico _produtoServico = ProdutoServico();
  bool _isProcessandoAcao = false;

  /// Retorna a cor semântica do Badge com base no Estado de Conservação.
  Color _obterCorEstadoConservacao(String estado) {
    switch (estado.toLowerCase()) {
      case 'novo com etiqueta':
        return Colors.green.shade700;
      case 'gentilmente usado':
        return Colors.teal.shade700;
      case 'marcas de uso visíveis':
        return Colors.orange.shade800;
      default:
        return const Color(0xFF8D6E63); // Cor Terra do Brechó
    }
  }

  /// Executa a reserva da peça no Firestore com proteção para Async Gap
  Future<void> _reservarPeca() async {
    setState(() {
      _isProcessandoAcao = true;
    });

    final erro = await _produtoServico.atualizarStatusProduto(
      widget.produto.id,
      'reservado',
    );

    if (!mounted) return;

    setState(() {
      _isProcessandoAcao = false;
    });

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peça reservada com sucesso! Entre em contato com o vendedor.'),
          backgroundColor: Color(0xFF2E7D32), // Verde Folha
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final produto = widget.produto;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalhes do Item',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32), // Verde Folha
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ÁREA DA IMAGEM DO PRODUTO COM BADGES OVERLAY
            Stack(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: produto.imagemUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(24.0),
                          child: Image.network(
                            produto.imagemUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.dry_cleaning,
                              size: 80,
                              color: Color(0xFF8D6E63),
                            ),
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.checkroom,
                              size: 80,
                              color: Color(0xFF2E7D32),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Imagem ilustrativa do item',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
                // Badge de Preço em Destaque
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      produto.precoFormatado,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. CARTÃO PRINCIPAL MATERIAL DESIGN 3 (Card)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: theme.colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categoria
                    Text(
                      produto.categoria.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Nome do Produto
                    Text(
                      produto.nome,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Divider(),
                    const SizedBox(height: 12),

                    // 3. SEÇÃO DE ATRIBUTOS CHAVE (Tamanho e Estado de Conservação)
                    Row(
                      children: [
                        // Chip do Tamanho
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tamanho',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  produto.tamanho,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Chip do Estado de Conservação
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Estado de Conservação',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 16,
                                      color: _obterCorEstadoConservacao(
                                        produto.estadoConservacao,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        produto.estadoConservacao,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _obterCorEstadoConservacao(
                                            produto.estadoConservacao,
                                          ),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 4. DESCRIÇÃO DO ITEM
                    const Text(
                      'Descrição da Peça',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      produto.descricao.isNotEmpty
                          ? produto.descricao
                          : 'O anunciante não incluiu detalhes adicionais.',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 5. BOTÃO DE AÇÃO PRINCIPAL (Reservar Peça)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed:
                    (_isProcessandoAcao || produto.status != 'disponivel')
                        ? null
                        : _reservarPeca,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32), // Verde Folha
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: _isProcessandoAcao
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.shopping_bag_outlined),
                label: Text(
                  produto.status == 'disponivel'
                      ? 'Tenho Interesse / Reservar Peça'
                      : 'Peça Indisponível (${produto.status.toUpperCase()})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
