import 'package:flutter/material.dart';

class LocationWiseStockPage extends StatefulWidget {
  const LocationWiseStockPage({super.key});

  @override
  State<LocationWiseStockPage> createState() => _LocationWiseStockPageState();
}

class _LocationWiseStockPageState extends State<LocationWiseStockPage> {
  final _locations = const ['Main Warehouse', 'Outlet A', 'Outlet B'];
  String _selected = 'Main Warehouse';

  final Map<String, List<Map<String, dynamic>>> _data = {
    'Main Warehouse': [
      {'name': 'Item A', 'qty': 40},
      {'name': 'Item B', 'qty': 0},
    ],
    'Outlet A': [
      {'name': 'Item A', 'qty': 5},
      {'name': 'Item C', 'qty': 12},
    ],
    'Outlet B': [
      {'name': 'Item D', 'qty': 7},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _data[_selected] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Wise Stock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selected,
              decoration: const InputDecoration(labelText: 'Location'),
              items: _locations
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setState(() => _selected = v ?? _selected),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final it = items[index];
                  final qty = it['qty'] as int;
                  final inStock = qty > 0;
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.15)),
                    ),
                    title: Text(it['name'] as String),
                    subtitle: Text('Qty: $qty'),
                    trailing: Icon(
                      inStock ? Icons.check_circle : Icons.error_outline,
                      color: inStock ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
