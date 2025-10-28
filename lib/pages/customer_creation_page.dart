import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_data_provider.dart';
import '../models/customer.dart';

class CustomerCreationPage extends StatefulWidget {
  const CustomerCreationPage({super.key});

  @override
  State<CustomerCreationPage> createState() => _CustomerCreationPageState();
}

class _CustomerCreationPageState extends State<CustomerCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<DatabaseDataProvider>();
    final customer = Customer(
      code: _code.text.trim(),
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      priceTier: 'RETAIL',
    );
    provider.addMockCustomer(customer);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Customer ${customer.name} created (mock).')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Creation')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('Create a new customer (mock only).', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _code,
                  decoration: const InputDecoration(labelText: 'Customer Code'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(labelText: 'Address'),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Save Customer (Mock)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
