import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_brecho/features/catalog/domain/produto_modelo.dart';

/// Serviço para gerenciamento da coleção 'produtos' no Cloud Firestore.
class ProdutoServico {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _colecao = 'produtos';

  /// Retorna um Stream em tempo real com os produtos disponíveis ordenados por data
  Stream<List<ProdutoModelo>> obterProdutosStream({String? categoriaFiltro}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(_colecao)
        .where('status', isEqualTo: 'disponivel');

    if (categoriaFiltro != null && categoriaFiltro.isNotEmpty) {
      query = query.where('categoria', isEqualTo: categoriaFiltro);
    }

    return query
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProdutoModelo.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Escuta as alterações de um produto específico em tempo real pelo ID
  Stream<ProdutoModelo?> obterProdutoPorIdStream(String id) {
    return _firestore
        .collection(_colecao)
        .doc(id)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return ProdutoModelo.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  /// Adiciona um novo produto ao acervo e atualiza o campo 'id' com o ID do documento
  Future<String?> cadastrarProduto(ProdutoModelo produto) async {
    try {
      final docRef = await _firestore.collection(_colecao).add(produto.toMap());
      await docRef.update({'id': docRef.id});
      return null; // Sucesso
    } on FirebaseException catch (e) {
      return 'Erro no banco de dados (${e.code}): ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao salvar o produto: $e';
    }
  }

  /// Atualiza o status do produto (ex: 'disponivel', 'reservado', 'vendido')
  Future<String?> atualizarStatusProduto(String idProduto, String novoStatus) async {
    try {
      await _firestore
          .collection(_colecao)
          .doc(idProduto)
          .update({'status': novoStatus});
      return null; // Sucesso
    } on FirebaseException catch (e) {
      return 'Erro ao atualizar o status: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao atualizar status: $e';
    }
  }

  /// Remove um produto do acervo
  Future<String?> excluirProduto(String idProduto) async {
    try {
      await _firestore.collection(_colecao).doc(idProduto).delete();
      return null; // Sucesso
    } on FirebaseException catch (e) {
      return 'Erro ao excluir produto: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao excluir produto: $e';
    }
  }
}
