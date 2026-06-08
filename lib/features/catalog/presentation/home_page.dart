import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _desapegosExemplo = [
    {'titulo': 'Jaqueta Jeans Vintage', 'preco': 'R\$ 79,90', 'tamanho': 'G', 'estado': 'Excelente'},
    {'titulo': 'Bolsa de Couro Marrom', 'preco': 'R\$ 45,00', 'tamanho': 'Único', 'estado': 'Bom'},
    {'titulo': 'Ténis Casual Verde', 'preco': 'R\$ 120,00', 'tamanho': '38', 'estado': 'Novo'},
    {'titulo': 'Camisa de Linho Branca', 'preco': 'R\$ 55,00', 'tamanho': 'M', 'estado': 'Excelente'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // CORREÇÃO: Utilizando theme.colorScheme.surface (antigo background)
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Brechó Comunitário'),
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
                  FilterChip(label: const Text('Casacos'), onSelected: (val) {}),
                  const SizedBox(width: 8),
                  FilterChip(label: const Text('Calçado'), onSelected: (val) {}),
                  const SizedBox(width: 8),
                  FilterChip(label: const Text('Tamanho M'), onSelected: (val) {}),
                  const SizedBox(width: 8),
                  FilterChip(label: const Text('Acessórios'), onSelected: (val) {}),
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
                  // Força o card a usar a cor de container do M3 caso queira contraste
                  color: theme.colorScheme.surfaceContainer,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 115,
                        width: double.infinity,
                        // CORREÇÃO: Substituído .withOpacity(0.15) por .withValues(alpha: 0.15)
                        color: theme.colorScheme.secondary.withValues(alpha: 0.15),
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                // CORREÇÃO: Substituído .withOpacity(0.1) por .withValues(alpha: 0.1)
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
                      )
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
