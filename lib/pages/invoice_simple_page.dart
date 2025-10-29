import 'package:flutter/material.dart';
import '../widgets/customer_select_dialog.dart';

class InvoiceSimplePage extends StatefulWidget {
  const InvoiceSimplePage({super.key});

  @override
  State<InvoiceSimplePage> createState() => _InvoiceSimplePageState();
}

class _InvoiceSimplePageState extends State<InvoiceSimplePage> {
  String _salesType = 'Retail';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Invoice',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => CustomerSelectDialog.show(context),
                    icon: const Icon(Icons.person_search_rounded),
                    label: const Text('Select Customer'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recall: not implemented')),
                    );
                  },
                  icon: const Icon(Icons.history_rounded),
                  tooltip: 'Recall',
                  iconSize: 22,
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(40, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final selected = await showModalBottomSheet<String>(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.storefront_rounded),
                            title: const Text('Retail'),
                            onTap: () => Navigator.of(context).pop('Retail'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.local_mall_rounded),
                            title: const Text('WholeSale'),
                            onTap: () => Navigator.of(context).pop('WholeSale'),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                );
                if (selected != null && mounted) {
                  setState(() => _salesType = selected);
                }
              },
              icon: const Icon(Icons.sell_rounded),
              label: Text('Sales Type: $_salesType'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Customer's Quotations: not implemented")),
                      );
                    },
                    icon: const Icon(Icons.description_rounded),
                    label: const Text("Customer's Quotations"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Customer's Sales Orders: not implemented")),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_rounded),
                    label: const Text("Customer's Sales Order"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
