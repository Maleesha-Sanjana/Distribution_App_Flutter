import 'package:flutter/material.dart';

class ToBeCollectedPage extends StatefulWidget {
  const ToBeCollectedPage({super.key});

  @override
  State<ToBeCollectedPage> createState() => _ToBeCollectedPageState();
}

class _ToBeCollectedPageState extends State<ToBeCollectedPage> {
  final _searchController = TextEditingController();
  String _filter = 'All';

  final _receivables = [
    {'customer': 'ABC Stores', 'due': 5600.00, 'age': '0-7 days'},
    {'customer': 'Sunrise Mart', 'due': 12800.00, 'age': '8-30 days'},
    {'customer': 'QuickBuy', 'due': 2200.00, 'age': '30+ days'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = _searchController.text.trim().toLowerCase();
    final filtered = _receivables.where((r) {
      final matchQ = q.isEmpty || (r['customer'] as String).toLowerCase().contains(q);
      final age = r['age'] as String;
      final matchFilter = _filter == 'All' || _filter == age;
      return matchQ && matchFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('To be Collected')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search customer',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _filter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: '0-7 days', child: Text('0-7 days')),
                    DropdownMenuItem(value: '8-30 days', child: Text('8-30 days')),
                    DropdownMenuItem(value: '30+ days', child: Text('30+ days')),
                  ],
                  onChanged: (v) => setState(() => _filter = v ?? 'All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final r = filtered[index];
                  final age = r['age'] as String;
                  Color color;
                  switch (age) {
                    case '0-7 days':
                      color = const Color(0xFF10B981);
                      break;
                    case '8-30 days':
                      color = const Color(0xFFF59E0B);
                      break;
                    default:
                      color = const Color(0xFFEF4444);
                  }
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.15)),
                    ),
                    leading: const Icon(Icons.payments_rounded),
                    title: Text(r['customer'] as String),
                    subtitle: Text('Age: $age'),
                    trailing: Chip(
                      label: Text('Rs. ${r['due']}'),
                      backgroundColor: color.withOpacity(0.12),
                      side: BorderSide(color: color.withOpacity(0.4)),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
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
