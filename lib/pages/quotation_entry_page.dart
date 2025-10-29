import 'package:flutter/material.dart';

class QuotationPage extends StatefulWidget {
  const QuotationPage({super.key});

  @override
  State<QuotationPage> createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  final _customerController = TextEditingController();
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  final List<Map<String, String>> _lines = [];

  @override
  void dispose() {
    _customerController.dispose();
    _itemController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addLine() {
    final item = _itemController.text.trim();
    final price = _priceController.text.trim();
    if (item.isEmpty || price.isEmpty) return;
    setState(() {
      _lines.add({'item': item, 'price': price});
      _itemController.clear();
      _priceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation'),
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
                      hintText: 'Enter item',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: 'Rs. ',
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
                        'No quotation lines',
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
                            side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.15)),
                          ),
                          title: Text(line['item'] ?? ''),
                          trailing: Text('Rs. ${line['price'] ?? '0.00'}'),
                          leading: const Icon(Icons.description_outlined),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _lines.isEmpty ? null : () {},
                child: const Text('Generate Quotation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
