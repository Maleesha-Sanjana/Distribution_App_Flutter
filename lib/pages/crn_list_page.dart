import 'package:flutter/material.dart';

class CrnListPage extends StatefulWidget {
  const CrnListPage({super.key});

  @override
  State<CrnListPage> createState() => _CrnListPageState();
}

class _CrnListPageState extends State<CrnListPage> {
  final _searchController = TextEditingController();
  final _returns = [
    {'no': 'CRN-2001', 'date': '2025-10-08', 'reason': 'Damaged', 'status': 'Approved'},
    {'no': 'CRN-2002', 'date': '2025-10-12', 'reason': 'Wrong item', 'status': 'Pending'},
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
    final filtered = _returns.where((r) => q.isEmpty || (r['no'] as String).toLowerCase().contains(q)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('CRN List')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search CRN no.',
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
                  final r = filtered[index];
                  final status = r['status'] as String;
                  final approved = status == 'Approved';
                  final color = approved ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.15)),
                    ),
                    leading: const Icon(Icons.assignment_return_rounded),
                    title: Text('${r['no']} · ${r['reason']}'),
                    subtitle: Text('Date: ${r['date']}'),
                    trailing: Chip(
                      label: Text(status),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      backgroundColor: color.withOpacity(0.15),
                      side: BorderSide(color: color.withOpacity(0.4)),
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
