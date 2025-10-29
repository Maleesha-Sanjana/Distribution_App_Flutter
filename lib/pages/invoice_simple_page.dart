import 'package:flutter/material.dart';
import '../widgets/customer_select_dialog.dart';

class InvoiceSimplePage extends StatefulWidget {
  const InvoiceSimplePage({super.key});

  @override
  State<InvoiceSimplePage> createState() => _InvoiceSimplePageState();
}

class _InvoiceSimplePageState extends State<InvoiceSimplePage> {
  String _salesType = 'Retail';
  final _manualController = TextEditingController();
  final _remarksController = TextEditingController();
  final List<Map<String, dynamic>> _rows = [];

  @override
  void dispose() {
    _manualController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _openRemarksDialog() async {
    final tempController = TextEditingController(text: _remarksController.text);
    await showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Remarks'),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: tempController,
              autofocus: true,
              maxLines: null,
              minLines: 6,
              decoration: const InputDecoration(
                hintText: 'Type remarks here...',
                border: OutlineInputBorder(),
                isDense: false,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _remarksController.text = tempController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Quotations: not implemented"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.description_rounded),
                    label: const Text("Quotations"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Sales Orders: not implemented"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_rounded),
                    label: const Text("Sales Order"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualController,
                    decoration: const InputDecoration(
                      hintText: 'Manual #',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _remarksController,
                    readOnly: true,
                    onTap: _openRemarksDialog,
                    decoration: const InputDecoration(
                      hintText: 'Remarks',
                      border: OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: Icon(Icons.open_in_full_rounded),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(children: [ 
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Item')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Discount')),
                      DataColumn(label: Text('Price')),
                    ],
                    rows: _rows
                        .map(
                          (r) => DataRow(
                            cells: [
                              DataCell(Text('${r['item']}')),
                              DataCell(Text('${r['qty']}')),
                              DataCell(Text('${r['discount']}')),
                              DataCell(Text('${r['price']}')),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
