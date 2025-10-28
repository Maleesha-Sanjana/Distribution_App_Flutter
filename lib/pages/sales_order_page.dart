import 'package:flutter/material.dart';

class SalesOrderPage extends StatefulWidget {
  const SalesOrderPage({super.key});

  @override
  State<SalesOrderPage> createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage> {
  final _customerController = TextEditingController();
  final _itemController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final List<Map<String, String>> _lines = [];

  @override
  void dispose() {
    _customerController.dispose();
    _itemController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _addLine() {
    final item = _itemController.text.trim();
    final qty = _qtyController.text.trim();
    if (item.isEmpty || qty.isEmpty) return;
    setState(() {
      _lines.add({
        'item': item,
        'qty': qty,
      });
      _itemController.clear();
      _qtyController.text = '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _customerController,
              decoration: const InputDecoration(
                labelText: 'Customer',
                hintText: 'Enter customer name',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(
                      labelText: 'Item',
                      hintText: 'Search or enter item',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _addLine,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _lines.isEmpty
                  ? Center(
                      child: Text(
                        'No items added',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      itemCount: _lines.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final line = _lines[index];
                        return ListTile(
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.15),
                            ),
                          ),
                          title: Text(line['item'] ?? ''),
                          trailing: Text('x${line['qty'] ?? '1'}'),
                          leading: const Icon(Icons.inventory_2_rounded),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _lines.isEmpty ? null : () {},
                child: const Text('Submit Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
