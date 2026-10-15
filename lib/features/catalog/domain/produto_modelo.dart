import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de dados que representa um produto no acervo do Brechó.
class ProdutoModelo {
  final String id;
  final String nome;
  final double preco;
  final String tamanho;
  final String categoria;
  final String estadoConservacao;
  final String status;
  final String descricao;
  final String vendedorId;
  final String imagemUrl;
  final DateTime criadoEm;

  ProdutoModelo({
    required this.id,
    required this.nome,
    required this.preco,
    required this.tamanho,
    required this.categoria,
    required this.estadoConservacao,
    this.status = 'disponivel',
    required this.descricao,
    required this.vendedorId,
    this.imagemUrl = '',
    required this.criadoEm,
  });

  /// Converte o objeto Dart para Map<String, dynamic> para salvar no Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'tamanho': tamanho,
      'categoria': categoria,
      'estadoConservacao': estadoConservacao,
      'status': status,
      'descricao': descricao,
      'vendedorId': vendedorId,
      'imagemUrl': imagemUrl,
      'criadoEm': Timestamp.fromDate(criadoEm),
    };
  }

  /// Constrói a instância de ProdutoModelo a partir de um documento do Firestore.
  factory ProdutoModelo.fromMap(Map<String, dynamic> map, String documentId) {
    return ProdutoModelo(
      id: documentId,
      nome: map['nome'] ?? '',
      preco: (map['preco'] as num?)?.toDouble() ?? 0.0,
      tamanho: map['tamanho'] ?? 'Único',
      categoria: map['categoria'] ?? 'Outros',
      estadoConservacao: map['estadoConservacao'] ?? 'Usado',
      status: map['status'] ?? 'disponivel',
      descricao: map['descricao'] ?? '',
      vendedorId: map['vendedorId'] ?? '',
      imagemUrl: map['imagemUrl'] ?? '',
      criadoEm: (map['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Método utilitário para formatar o preço em Real Brasileiro (R$)
  String get precoFormatado => 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
}
