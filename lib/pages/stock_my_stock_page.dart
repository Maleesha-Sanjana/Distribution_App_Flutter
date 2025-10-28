import 'package:flutter/material.dart';

class MyStockPage extends StatefulWidget {
  const MyStockPage({super.key});

  @override
  State<MyStockPage> createState() => _MyStockPageState();
}

class _MyStockPageState extends State<MyStockPage> {
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> _items = [
    {'name': 'Item A', 'qty': 25},
    {'name': 'Item B', 'qty': 0},
    {'name': 'Item C', 'qty': 7},
    {'name': 'Item D', 'qty': 120},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _items.where((e) {
      final q = _searchController.text.trim().toLowerCase();
      return q.isEmpty || (e['name'] as String).toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search item',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final it = filtered[index];
                  final qty = it['qty'] as int;
                  final inStock = qty > 0;
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.15)),
                    ),
                    title: Text(it['name']),
                    subtitle: Text('Qty: $qty'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (inStock ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2)),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: (inStock ? const Color(0xFF34D399) : const Color(0xFFEF4444)).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        inStock ? 'In stock' : 'Out of stock',
                        style: TextStyle(
                          color: inStock ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
