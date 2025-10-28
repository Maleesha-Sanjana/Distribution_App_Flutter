import 'package:flutter/material.dart';

class MyInvoicePage extends StatefulWidget {
  const MyInvoicePage({super.key});

  @override
  State<MyInvoicePage> createState() => _MyInvoicePageState();
}

class _MyInvoicePageState extends State<MyInvoicePage> {
  final _searchController = TextEditingController();
  String _status = 'All';

  final _invoices = [
    {'no': 'INV-1001', 'date': '2025-10-10', 'amount': 12500.00, 'status': 'Paid'},
    {'no': 'INV-1002', 'date': '2025-10-12', 'amount': 8200.50, 'status': 'Unpaid'},
    {'no': 'INV-1003', 'date': '2025-10-14', 'amount': 4300.00, 'status': 'Partially Paid'},
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
    final filtered = _invoices.where((inv) {
      final matchQ = q.isEmpty || (inv['no'] as String).toLowerCase().contains(q);
      final matchStatus = _status == 'All' || inv['status'] == _status;
      return matchQ && matchStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My invoice')),
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
                      labelText: 'Search invoice no.',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                    DropdownMenuItem(value: 'Partially Paid', child: Text('Partially Paid')),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 'All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final inv = filtered[index];
                  final status = inv['status'] as String;
                  final paid = status == 'Paid';
                  final partially = status == 'Partially Paid';
                  final color = paid
                      ? const Color(0xFF10B981)
                      : partially
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFEF4444);
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.15)),
                    ),
                    title: Text('${inv['no']} · Rs. ${inv['amount']}'),
                    subtitle: Text('Date: ${inv['date']}'),
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
