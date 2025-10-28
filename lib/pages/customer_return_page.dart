import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_data_provider.dart';
import '../models/food_item.dart';

class CustomerReturnPage extends StatefulWidget {
  const CustomerReturnPage({super.key});

  @override
  State<CustomerReturnPage> createState() => _CustomerReturnPageState();
}

class _CustomerReturnPageState extends State<CustomerReturnPage> {
  String? _selectedCustomerCode;
  FoodItem? _selectedItem;
  final _qty = TextEditingController(text: '1');
  final _note = TextEditingController();

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final qty = int.tryParse(_qty.text.trim());
    if (_selectedCustomerCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }
    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item')),
      );
      return;
    }
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    final provider = context.read<DatabaseDataProvider>();
    provider.addMockReturn(
      customerCode: _selectedCustomerCode!,
      items: [
        {
          'productCode': _selectedItem!.productCode,
          'name': _selectedItem!.name,
          'qty': qty,
        }
      ],
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer return saved (mock).')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final database = context.watch<DatabaseDataProvider>();
    final customers = database.customers;
    final products = database.menuItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Return')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Record a customer return (mock).'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Customer'),
                value: _selectedCustomerCode,
                items: customers
                    .map((c) => DropdownMenuItem(
                          value: c.code,
                          child: Text('${c.name} (${c.code})'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCustomerCode = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<FoodItem>(
                decoration: const InputDecoration(labelText: 'Item'),
                value: _selectedItem,
                items: products
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text('${p.name} (${p.productCode})'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedItem = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qty,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _note,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _save,
                child: const Text('Save Return (Mock)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
