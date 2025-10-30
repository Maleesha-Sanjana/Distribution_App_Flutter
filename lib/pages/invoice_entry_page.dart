import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class InvoiceSimplePage extends StatefulWidget {
  const InvoiceSimplePage({super.key});

  @override
  State<InvoiceSimplePage> createState() => _InvoiceSimplePageState();
}

class _CustomerSelectionDialog extends StatefulWidget {
  const _CustomerSelectionDialog({
    required this.customers,
  });

  final List<Map<String, String>> customers;

  @override
  State<_CustomerSelectionDialog> createState() => _CustomerSelectionDialogState();
}

class _CustomerSelectionDialogState extends State<_CustomerSelectionDialog> {
  late final TextEditingController _searchController;
  late List<Map<String, String>> _filteredCustomers;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCustomers = List.from(widget.customers);
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void didUpdateWidget(covariant _CustomerSelectionDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.customers, widget.customers)) {
      _applyFilter(_searchController.text);
    }
  }

  void _handleSearchChanged() {
    _applyFilter(_searchController.text);
  }

  void _applyFilter(String query) {
    final lowerQuery = query.trim().toLowerCase();
    setState(() {
      if (lowerQuery.isEmpty) {
        _filteredCustomers = List.from(widget.customers);
        return;
      }

      _filteredCustomers = widget.customers.where((customer) {
        final code = customer['code']?.toLowerCase() ?? '';
        final name = customer['name']?.toLowerCase() ?? '';
        final phone = customer['phone']?.toLowerCase() ?? '';
        return code.contains(lowerQuery) || name.contains(lowerQuery) || phone.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final keyboardOpen = media.viewInsets.bottom > 0;
    final availableHeight = media.size.height - media.viewInsets.bottom - 160;
    double dialogHeight;

    if (availableHeight.isFinite && availableHeight > 0) {
      dialogHeight = availableHeight;
      if (dialogHeight > 480.0) dialogHeight = 480.0;
      final minHeight = keyboardOpen ? 220.0 : 260.0;
      if (dialogHeight < minHeight) dialogHeight = minHeight;
    } else {
      dialogHeight = media.size.height * 0.6;
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text('Select Customer'),
      content: SizedBox(
        width: double.maxFinite,
        height: dialogHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search by name, code, phone',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredCustomers.isEmpty
                  ? const Center(child: Text('No customers found'))
                  : ListView.separated(
                      itemCount: _filteredCustomers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];
                        final code = customer['code'] ?? '';
                        final name = customer['name'] ?? '';
                        final phone = customer['phone'] ?? '';
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            foregroundColor: theme.colorScheme.onSecondaryContainer,
                            child: const Icon(Icons.person_rounded),
                          ),
                          title: Text('$code • $name'),
                          subtitle: Text(phone),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).pop(customer);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(<String, String>{}),
          child: const Text('None'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DiscountValidationResult {
  const _DiscountValidationResult({
    this.errorMessage,
    this.itemLabel,
    this.quantity,
    this.freeQuantity,
    this.discountLabel,
    this.finalPrice,
    this.summary,
  });

  final String? errorMessage;
  final String? itemLabel;
  final int? quantity;
  final int? freeQuantity;
  final String? discountLabel;
  final double? finalPrice;
  final String? summary;
}

class _InvoiceSimplePageState extends State<InvoiceSimplePage> {
  String _salesType = 'Retail';
  final _manualController = TextEditingController();
  final _remarksController = TextEditingController();
  final List<Map<String, dynamic>> _rows = [];
  Map<String, String>? _selectedQuotation;
  Map<String, String>? _selectedSalesOrder;
  Map<String, String>? _selectedCustomer;

  static const List<Map<String, String>> _mockQuotations = [
    {
      'id': 'QT-1001',
      'customer': 'Acme Traders',
      'date': '12 Aug 2024',
      'amount': 'Rs. 32,500.00',
    },
    {
      'id': 'QT-1005',
      'customer': 'Sunrise Mart',
      'date': '03 Sep 2024',
      'amount': 'Rs. 18,200.00',
    },
    {
      'id': 'QT-1010',
      'customer': 'Global Industries',
      'date': '21 Sep 2024',
      'amount': 'Rs. 44,950.00',
    },
  ];

  static const List<Map<String, String>> _mockCustomers = [
    {'code': 'C001', 'name': 'Sun Plastics', 'phone': '+94 77 123 4567'},
    {'code': 'C002', 'name': 'Green Polywares', 'phone': '+94 71 987 6543'},
    {'code': 'C003', 'name': 'Ocean Polymers', 'phone': '+94 76 555 1122'},
    {'code': 'C004', 'name': 'City Household Mart', 'phone': '+94 70 333 7788'},
    {'code': 'C005', 'name': 'Budget Plastics', 'phone': '+94 72 222 4499'},
  ];

  static const List<Map<String, String>> _mockSalesOrders = [
    {
      'id': 'SO-2308',
      'customer': 'Lotus Stores',
      'date': '08 Oct 2024',
      'amount': 'Rs. 56,780.00',
    },
    {
      'id': 'SO-2312',
      'customer': 'Evergreen Retail',
      'date': '11 Oct 2024',
      'amount': 'Rs. 24,990.00',
    },
    {
      'id': 'SO-2320',
      'customer': 'Nova Enterprises',
      'date': '18 Oct 2024',
      'amount': 'Rs. 87,400.00',
    },
  ];

  static const List<Map<String, dynamic>> _mockItems = [
    {
      'code': 'ITM-001',
      'name': '1L Water Bottle',
      'uom': 'pcs',
      'price': 450.00,
    },
    {
      'code': 'ITM-002',
      'name': 'Plastic Container Set',
      'uom': 'set',
      'price': 1290.00,
    },
    {
      'code': 'ITM-003',
      'name': 'Food Storage Box',
      'uom': 'pcs',
      'price': 380.00,
    },
    {
      'code': 'ITM-004',
      'name': 'Lunch Carrier Deluxe',
      'uom': 'pcs',
      'price': 950.00,
    },
    {
      'code': 'ITM-005',
      'name': 'Stackable Jar Set',
      'uom': 'set',
      'price': 720.00,
    },
    {
      'code': 'ITM-006',
      'name': 'Ice Cube Tray 12 Grid',
      'uom': 'pcs',
      'price': 210.00,
    },
  ];

  @override
  void dispose() {
    _manualController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  _DiscountValidationResult _validateDiscount({
    required Map<String, dynamic>? selectedItem,
    required String quantityText,
    required String freeQuantityText,
    required String discountText,
    required bool useAmountDiscount,
  }) {
    if (selectedItem == null) {
      return const _DiscountValidationResult(errorMessage: 'Select an item first.');
    }

    final quantity = int.tryParse(quantityText.trim());
    if (quantity == null || quantity <= 0) {
      return const _DiscountValidationResult(errorMessage: 'Quantity must be above zero.');
    }

    final freeQuantity = int.tryParse(freeQuantityText.trim().isEmpty ? '0' : freeQuantityText.trim());
    if (freeQuantity == null || freeQuantity < 0) {
      return const _DiscountValidationResult(errorMessage: 'Enter a valid free quantity.');
    }

    final discountValue = double.tryParse(discountText.trim().isEmpty ? '0' : discountText.trim());
    if (discountValue == null || discountValue < 0) {
      return const _DiscountValidationResult(errorMessage: 'Enter a valid discount.');
    }

    final unitPrice = (selectedItem['price'] as num).toDouble();
    final totalPrice = unitPrice * quantity;
    double discountAmount;

    if (!useAmountDiscount) {
      if (discountValue > 100) {
        return const _DiscountValidationResult(
          errorMessage: 'Discount % cannot exceed 100.',
        );
      }
      discountAmount = totalPrice * (discountValue / 100);
    } else {
      if (discountValue > totalPrice) {
        return const _DiscountValidationResult(
          errorMessage: 'Discount exceeds total.',
        );
      }
      discountAmount = discountValue;
    }

    double finalPrice = totalPrice - discountAmount;
    if (finalPrice < 0) {
      finalPrice = 0;
    }
    finalPrice = double.parse(finalPrice.toStringAsFixed(2));

    final discountLabel = useAmountDiscount
        ? 'Rs ${discountAmount.toStringAsFixed(2)}'
        : '${discountValue.toStringAsFixed(2)}%';

    final summary = '${useAmountDiscount ? 'Flat' : 'Percent'} discount • Net Rs ${finalPrice.toStringAsFixed(2)}';

    return _DiscountValidationResult(
      itemLabel: '${selectedItem['code']} • ${selectedItem['name']}',
      quantity: quantity,
      freeQuantity: freeQuantity,
      discountLabel: discountLabel,
      finalPrice: finalPrice,
      summary: summary,
    );
  }

  Future<Map<String, String>?> _showCustomerDialog() {
    return showDialog<Map<String, String>?>(
      context: context,
      builder: (dialogContext) => _CustomerSelectionDialog(customers: _mockCustomers),
    );
  }

  Future<void> _openAddItemDialog() async {
    final searchController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final discountController = TextEditingController(text: '0');
    final freeQtyController = TextEditingController(text: '0');
    String? errorText;
    Map<String, dynamic>? selectedItem;
    List<Map<String, dynamic>> filteredItems = const [];
    bool hasQuery = false;
    String? discountSummary;
    bool useAmountDiscount = false;
    final List<Map<String, dynamic>> pendingEntries = [];

    bool matchesQuery(Map<String, dynamic> item, String query) {
      final lower = query.toLowerCase();
      return (item['code'] as String).toLowerCase().contains(lower) ||
          (item['name'] as String).toLowerCase().contains(lower);
    }

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            void refreshSummary() {
              if (selectedItem == null) {
                setDialogState(() {
                  errorText = null;
                  discountSummary = null;
                });
                return;
              }

              final validation = _validateDiscount(
                selectedItem: selectedItem,
                quantityText: qtyController.text,
                freeQuantityText: freeQtyController.text,
                discountText: discountController.text,
                useAmountDiscount: useAmountDiscount,
              );

              setDialogState(() {
                if (validation.errorMessage != null) {
                  errorText = validation.errorMessage;
                  discountSummary = null;
                } else {
                  errorText = null;
                  discountSummary = validation.summary;
                }
              });
            }
            void applyFilter(String query) {
              setDialogState(() {
                hasQuery = query.isNotEmpty;
                filteredItems = query.isEmpty
                    ? const []
                    : _mockItems
                        .where((item) => matchesQuery(item, query))
                        .toList();
              });
            }

            void resetForm() {
              qtyController.text = '1';
              freeQtyController.text = '0';
              discountController.text = '0';
              discountSummary = null;
            }

            Future<void> openNumberEntry({
              required String title,
              required TextEditingController controller,
              bool allowDecimal = false,
            }) async {
              final tempController = TextEditingController(text: controller.text);
              final result = await showDialog<String?>(
                context: dialogContext,
                builder: (context) {
                  return AlertDialog(
                    title: Text(title),
                    content: TextField(
                      controller: tempController,
                      autofocus: true,
                      keyboardType: allowDecimal
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.number,
                      inputFormatters: allowDecimal
                          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                          : [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(tempController.text.trim()),
                        child: const Text('Set'),
                      ),
                    ],
                  );
                },
              );

              if (result == null) {
                return;
              }

              setDialogState(() {
                final fallback = allowDecimal ? '0' : '0';
                final value = result.isEmpty ? fallback : result;
                if (allowDecimal) {
                  final parsed = double.tryParse(value);
                  controller.text = parsed == null ? fallback : parsed.toString();
                } else {
                  final parsed = int.tryParse(value);
                  controller.text = parsed == null ? fallback : parsed.toString();
                }
                errorText = null;
              });

              if (selectedItem != null) {
                refreshSummary();
              }
            }

            void addPendingEntry() {
              final validation = _validateDiscount(
                selectedItem: selectedItem,
                quantityText: qtyController.text,
                freeQuantityText: freeQtyController.text,
                discountText: discountController.text,
                useAmountDiscount: useAmountDiscount,
              );

              if (validation.errorMessage != null) {
                setDialogState(() {
                  errorText = validation.errorMessage;
                });
                return;
              }

              setDialogState(() {
                pendingEntries.add({
                  'item': validation.itemLabel,
                  'qty': validation.quantity,
                  'freeQty': validation.freeQuantity ?? 0,
                  'discount': validation.discountLabel,
                  'price': validation.finalPrice,
                });
                errorText = null;
                discountSummary = validation.summary;
              });
              resetForm();
            }

            return AlertDialog(
              title: const Text('Add Item'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search item by code or name',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                        onChanged: (value) => applyFilter(value),
                      ),
                      const SizedBox(height: 12),
                      if (hasQuery)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: Material(
                            color: Colors.transparent,
                            child: filteredItems.isEmpty
                                ? Center(
                                    child: Text(
                                      'No items match your search',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: filteredItems.length,
                                    separatorBuilder: (_, __) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final item = filteredItems[index];
                                      final isSelected =
                                          selectedItem != null && selectedItem!['code'] == item['code'];
                                      return ListTile(
                                        selected: isSelected,
                                        selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor: theme.colorScheme.primaryContainer,
                                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                                          child: Text(
                                            (item['code'] as String).substring(0, 2),
                                          ),
                                        ),
                                        title: Text('${item['code']} • ${item['name']}'),
                                        subtitle: Text(
                                          'Rs ${(item['price'] as num).toStringAsFixed(2)} per ${item['uom']}',
                                        ),
                                        onTap: () {
                                          setDialogState(() {
                                            selectedItem = item;
                                            searchController.text = item['name'] as String;
                                            filteredItems = _mockItems
                                                .where((element) => matchesQuery(element, searchController.text))
                                                .toList();
                                            discountSummary = null;
                                            useAmountDiscount = false;
                                            errorText = null;
                                          });
                                          refreshSummary();
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (selectedItem != null)
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedItem!['name'] as String,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Code: ${selectedItem!['code']} • UoM: ${selectedItem!['uom']}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Unit Price: Rs ${(selectedItem!['price'] as num).toStringAsFixed(2)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: useAmountDiscount,
                            onChanged: (value) {
                              setDialogState(() {
                                useAmountDiscount = value ?? false;
                                final quantity = int.tryParse(qtyController.text.trim());
                                final freeQty = int.tryParse(freeQtyController.text.trim());
                                final discountValue = double.tryParse(
                                  discountController.text.trim().isEmpty
                                      ? '0'
                                      : discountController.text.trim(),
                                );

                                if (selectedItem != null &&
                                    quantity != null &&
                                    quantity > 0 &&
                                    freeQty != null &&
                                    freeQty >= 0) {
                                  final unitPrice = (selectedItem!['price'] as num).toDouble();
                                  final totalPrice = unitPrice * quantity;

                                  if (discountValue != null) {
                                    double convertedValue;
                                    if (useAmountDiscount) {
                                      convertedValue = totalPrice * (discountValue / 100);
                                    } else {
                                      convertedValue = totalPrice == 0
                                          ? 0
                                          : (discountValue / totalPrice) * 100;
                                    }

                                    discountController.text = convertedValue.isFinite
                                        ? convertedValue.toStringAsFixed(2)
                                        : '0';
                                  }
                                }

                                discountSummary = null;
                                errorText = null;
                              });
                              if (selectedItem != null) {
                                refreshSummary();
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            useAmountDiscount ? 'Flat discount' : '% discount',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: qtyController,
                              readOnly: true,
                              onTap: () => openNumberEntry(
                                title: 'Enter Quantity',
                                controller: qtyController,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Qty',
                                prefixIcon: Icon(Icons.numbers_rounded),
                                suffixIcon: Icon(Icons.edit_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: freeQtyController,
                              readOnly: true,
                              onTap: () => openNumberEntry(
                                title: 'Enter Free Quantity',
                                controller: freeQtyController,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Free',
                                prefixIcon: Icon(Icons.card_giftcard_rounded),
                                suffixIcon: Icon(Icons.edit_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: discountController,
                              readOnly: true,
                              onTap: () => openNumberEntry(
                                title: 'Enter Discount',
                                controller: discountController,
                                allowDecimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Discount',
                                suffixText: useAmountDiscount ? null : '%',
                                suffixIcon: const Icon(Icons.edit_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (discountSummary != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                discountSummary!,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (errorText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          errorText!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text('Pending Items', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: pendingEntries.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: Text('No items added yet')),
                              )
                            : ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 220),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
                                    columnSpacing: 12,
                                    dataRowMinHeight: 44,
                                    columns: const [
                                      DataColumn(label: Text('Item')),
                                      DataColumn(label: Text('Qty'), numeric: true),
                                      DataColumn(label: Text('Free'), numeric: true),
                                      DataColumn(label: Text('Disc')), 
                                      DataColumn(label: Text('Net'), numeric: true),
                                      DataColumn(label: Text('')),
                                    ],
                                    rows: pendingEntries
                                        .asMap()
                                        .entries
                                        .map(
                                          (entry) => DataRow(
                                            cells: [
                                              DataCell(Text(
                                                _shortItemLabel(entry.value['item'] as String? ?? ''),
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                              DataCell(Text('${entry.value['qty']}')),
                                              DataCell(Text('${entry.value['freeQty']}')),
                                              DataCell(Text('${entry.value['discount']}')),
                                              DataCell(Text('Rs ${(entry.value['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}')),
                                              DataCell(
                                                IconButton(
                                                  tooltip: 'Remove',
                                                  icon: const Icon(Icons.delete_outline_rounded),
                                                  onPressed: () {
                                                    setDialogState(() {
                                                      pendingEntries.removeAt(entry.key);
                                                    });
                                                  },
                                                ),
                                              ),
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
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: IconButton(
                        tooltip: 'Cancel',
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                        style: IconButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          backgroundColor: theme.colorScheme.error.withOpacity(0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: IconButton(
                        tooltip: 'Add item',
                        onPressed: () {
                          addPendingEntry();
                        },
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(
                          foregroundColor: theme.colorScheme.onPrimary,
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: IconButton(
                        tooltip: 'Add & confirm',
                        onPressed: () {
                          if (pendingEntries.isEmpty) {
                            setDialogState(() {
                              errorText = 'Add at least one entry before confirming.';
                            });
                            return;
                          }

                          Navigator.of(dialogContext).pop({
                            'rows': pendingEntries.map((e) => Map<String, dynamic>.from(e)).toList(),
                            'confirm': true,
                          });
                        },
                        icon: const Icon(Icons.check_circle_rounded),
                        style: IconButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSecondary,
                          backgroundColor: theme.colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      final List<dynamic>? rows = result['rows'] as List<dynamic>?;
      final bool shouldConfirm = result['confirm'] == true;

      if (rows != null && rows.isNotEmpty) {
        setState(() {
          _rows.addAll(rows.cast<Map<String, dynamic>>());
        });
      }

      if (shouldConfirm && rows != null && rows.isNotEmpty) {
        await _showInvoiceSummary();
      }
    }
  }

  double _calculateSubTotal() {
    return _rows.fold<double>(0, (sum, row) => sum + ((row['price'] as num?)?.toDouble() ?? 0.0));
  }

  String _shortItemLabel(String? label) {
    if (label == null || label.isEmpty) return '';
    final parts = label.split('•');
    final trimmed = parts.first.trim();
    return trimmed.length <= 12 ? trimmed : '${trimmed.substring(0, 12)}…';
  }

  Future<void> _showInvoiceSummary() async {
    if (_rows.isEmpty) {
      return;
    }

    final subtotal = _calculateSubTotal();
    final customer = _selectedCustomer?['name'] ?? 'N/A';
    final quotation = _selectedQuotation?['id'] ?? 'None';
    final salesOrder = _selectedSalesOrder?['id'] ?? 'None';

    await showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Confirm Invoice'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: $customer', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text('Quotation: $quotation', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text('Sales Order: $salesOrder', style: theme.textTheme.bodyMedium),
              const Divider(height: 24),
              Text('Items: ${_rows.length}', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text('Subtotal: Rs ${subtotal.toStringAsFixed(2)}', style: theme.textTheme.titleMedium),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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

  Future<Map<String, String>?> _showMockDataDialog({
    required String title,
    required List<Map<String, String>> data,
    required IconData icon,
  }) async {
    return showDialog<Map<String, String>?>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: data.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No records available'),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = data[index];
                      final id = entry['id'] ?? '';
                      final customer = entry['customer'] ?? '';
                      final date = entry['date'] ?? '';
                      final amount = entry['amount'] ?? '';
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                          child: Icon(icon),
                        ),
                        title: Text('$id • $customer'),
                        subtitle: Text('$date • $amount'),
                        onTap: () => Navigator.of(dialogContext).pop(entry),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(<String, String>{}),
              child: const Text('None'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openDiscountTaxesDialog() async {
    final discountCtrl = TextEditingController();
    final taxCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Discount & Taxes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: discountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Discount %',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: taxCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Tax %',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
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
                final d = double.tryParse(discountCtrl.text.trim());
                final t = double.tryParse(taxCtrl.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Discount: ${d?.toStringAsFixed(2) ?? '-'}% • Tax: ${t?.toStringAsFixed(2) ?? '-'}%'),
                  ),
                );
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
                  child: Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      final customerName = cart.customerName;
                      final displayLabel = _selectedCustomer?['name'] ?? customerName ?? 'Select Customer';
                      return ElevatedButton.icon(
                        onPressed: () async {
                          final selection = await _showCustomerDialog();
                          if (!mounted || selection == null) return;
                          setState(() {
                            if (selection.isEmpty) {
                              _selectedCustomer = null;
                              cart.setCustomerInfo(name: null);
                            } else {
                              _selectedCustomer = selection;
                              cart.setCustomerInfo(name: selection['name']);
                            }
                          });
                        },
                        icon: const Icon(Icons.person_rounded),
                        label: Text(
                          displayLabel,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                        ),
                      );
                    },
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
                    onPressed: () async {
                      final selection = await _showMockDataDialog(
                        title: 'Recent Quotations',
                        data: _mockQuotations,
                        icon: Icons.description_rounded,
                      );
                      if (!mounted) return;
                      setState(() {
                        if (selection == null) {
                          return;
                        }
                        if (selection.isEmpty) {
                          _selectedQuotation = null;
                        } else {
                          _selectedQuotation = selection;
                        }
                      });
                    },
                    icon: const Icon(Icons.description_rounded),
                    label: Text(
                      _selectedQuotation == null
                          ? 'Quotations'
                          : _selectedQuotation!['id'] ?? '',
                    ),
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
                    onPressed: () async {
                      final selection = await _showMockDataDialog(
                        title: 'Recent Sales Orders',
                        data: _mockSalesOrders,
                        icon: Icons.shopping_cart_rounded,
                      );
                      if (!mounted) return;
                      setState(() {
                        if (selection == null) {
                          return;
                        }
                        if (selection.isEmpty) {
                          _selectedSalesOrder = null;
                        } else {
                          _selectedSalesOrder = selection;
                        }
                      });
                    },
                    icon: const Icon(Icons.shopping_cart_rounded),
                    label: Text(
                      _selectedSalesOrder == null
                          ? 'Sales Order'
                          : _selectedSalesOrder!['id'] ?? '',
                    ),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Use the full available width for the table
                    return DataTable(
                      columnSpacing: 12,
                      dataRowMinHeight: 48,
                      dataRowMaxHeight: 72,
                      columns: [
                        DataColumn(
                          label: const Text('Item'),
                          numeric: false,
                        ),
                        DataColumn(
                          label: const Text('Qty'),
                          numeric: true,
                        ),
                        DataColumn(
                          label: const Text('Free'),
                          numeric: true,
                        ),
                        DataColumn(
                          label: const Text('Discount'),
                          numeric: true,
                        ),
                        DataColumn(
                          label: const Text('Price'),
                          numeric: true,
                        ),
                      ],
                      rows: _rows
                          .map(
                            (r) => DataRow(
                              cells: [
                                DataCell(Text(
                                  _shortItemLabel(r['item'] as String?),
                                  overflow: TextOverflow.ellipsis,
                                )),
                                DataCell(Text(
                                  '${r['qty']}',
                                  textAlign: TextAlign.end,
                                )),
                                DataCell(Text(
                                  '${r['freeQty'] ?? 0}',
                                  textAlign: TextAlign.end,
                                )),
                                DataCell(Text(
                                  '${r['discount']}',
                                  textAlign: TextAlign.end,
                                )),
                                DataCell(Text(
                                  '${r['price']}',
                                  textAlign: TextAlign.end,
                                )),
                              ],
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openAddItemDialog,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Item'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openDiscountTaxesDialog,
                    icon: const Icon(Icons.percent_rounded),
                    label: const Text('Discount & Taxes'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  tooltip: 'Temporary Save',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Temporarily saved')),
                    );
                  },
                  icon: const Icon(Icons.save_rounded),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    minimumSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _rows.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Table cleared')),
                      );
                    },
                    child: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      const methods = <String>[
                        'Cash',
                        'Master Card',
                        'Visa Card',
                        'Amex Card',
                        'Credit',
                        'Cheque',
                        'Third Party Cheque',
                        'COD',
                        'Direct Deposit',
                        'Online',
                      ];
                      String? selected = methods.first;
                      await showDialog<void>(
                        context: context,
                        builder: (context) {
                          final theme = Theme.of(context);
                          return StatefulBuilder(
                            builder: (context, setLocalState) {
                              final amountCtrl = TextEditingController();
                              final cardNumberCtrl = TextEditingController();
                              final chequeNumberCtrl = TextEditingController();
                              final bankCtrl = TextEditingController();
                              final branchCtrl = TextEditingController();
                              final dateCtrl = TextEditingController();
                              final codNumberCtrl = TextEditingController();
                              final depositNumberCtrl = TextEditingController();
                              DateTime? selectedDate;

                              List<Widget> buildFields() {
                                final widgets = <Widget>[
                                  DropdownButtonFormField<String>(
                                    value: selected,
                                    items: methods
                                        .map((m) => DropdownMenuItem<String>(
                                              value: m,
                                              child: Text(m),
                                            ))
                                        .toList(),
                                    onChanged: (v) => setLocalState(() => selected = v),
                                    decoration: const InputDecoration(
                                      labelText: 'Payment Method',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ];

                                void addGap() => widgets.add(const SizedBox(height: 12));

                                switch (selected) {
                                  case 'Cash':
                                  case 'Visa Card':
                                  case 'Amex Card':
                                  case 'Credit':
                                  case 'Online':
                                    addGap();
                                    widgets.add(TextField(
                                      controller: amountCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Amount',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ));
                                    break;
                                  case 'Master Card':
                                    addGap();
                                    widgets.add(TextField(
                                      controller: cardNumberCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Master Card Number',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ));
                                    addGap();
                                    widgets.add(TextField(
                                      controller: amountCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Amount',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ));
                                    break;
                                  case 'Cheque':
                                  case 'Third Party Cheque':
                                    addGap();
                                    widgets.add(TextField(
                                      controller: chequeNumberCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: 'Cheque Number (6 digits)',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ));
                                    addGap();
                                    widgets.add(TextField(
                                      controller: bankCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Bank',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ));
                                    addGap();
                                    widgets.add(TextField(
                                      controller: branchCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Branch',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ));
                                    addGap();
                                    widgets.add(TextField(
                                      controller: dateCtrl,
                                      readOnly: true,
                                      onTap: () async {
                                        final now = DateTime.now();
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: selectedDate ?? now,
                                          firstDate: DateTime(now.year - 5),
                                          lastDate: DateTime(now.year + 5),
                                        );
                                        if (picked != null) {
                                          setLocalState(() {
                                            selectedDate = picked;
                                            dateCtrl.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                          });
                                        }
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Date',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        suffixIcon: Icon(Icons.calendar_today_rounded),
                                      ),
                                    ));
                                    addGap();
                                    widgets.add(TextField(
                                      controller: amountCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Amount',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ));
                                    break;
                                  case 'COD':
                                    addGap();
                                    widgets.add(TextField(
                                      controller: amountCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Amount',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ));
                                    addGap();
                                    widgets.add(TextField(
                                      controller: codNumberCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'COD Number',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ));
                                    break;
                                  case 'Direct Deposit':
                                    addGap();
                                    widgets.add(TextField(
                                      controller: depositNumberCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Deposit Number',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ));
                                    addGap();
                                    widgets.add(TextField(
                                      controller: bankCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Bank',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ));
                                    addGap();
                                    widgets.add(TextField(
                                      controller: branchCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Branch',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ));
                                    addGap();
                                    widgets.add(TextField(
                                      controller: amountCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Amount',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ));
                                    break;
                                }

                                return widgets;
                              }

                              bool validate() {
                                double? amountOrNull() {
                                  final a = double.tryParse(amountCtrl.text.trim());
                                  return a;
                                }

                                switch (selected) {
                                  case 'Cash':
                                  case 'Visa Card':
                                  case 'Amex Card':
                                  case 'Credit':
                                  case 'Online':
                                    final a = amountOrNull();
                                    if (a == null || a <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Enter a valid amount')),
                                      );
                                      return false;
                                    }
                                    return true;
                                  case 'Master Card':
                                    if (cardNumberCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Enter Master Card number')),
                                      );
                                      return false;
                                    }
                                    final a = amountOrNull();
                                    if (a == null || a <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Enter a valid amount')),
                                      );
                                      return false;
                                    }
                                    return true;
                                  case 'Cheque':
                                  case 'Third Party Cheque':
                                    final num = chequeNumberCtrl.text.trim();
                                    if (num.length != 6 || int.tryParse(num) == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Cheque number must be exactly 6 digits')),
                                      );
                                      return false;
                                    }
                                    if (bankCtrl.text.trim().isEmpty || branchCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Enter bank and branch')),
                                      );
                                      return false;
                                    }
                                    if (dateCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Select cheque date')),
                                      );
                                      return false;
                                    }
                                    final a = amountOrNull();
                                    if (a == null || a <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Enter a valid amount')),
                                      );
                                      return false;
                                    }
                                    return true;
                                  case 'COD':
                                    if (codNumberCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Enter COD number')),
                                      );
                                      return false;
                                    }
                                    final a = amountOrNull();
                                    if (a == null || a <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Enter a valid amount')),
                                      );
                                      return false;
                                    }
                                    return true;
                                  case 'Direct Deposit':
                                    if (depositNumberCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Enter deposit number')),
                                      );
                                      return false;
                                    }
                                    if (bankCtrl.text.trim().isEmpty || branchCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Enter bank and branch')),
                                      );
                                      return false;
                                    }
                                    final a = amountOrNull();
                                    if (a == null || a <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Enter a valid amount')),
                                      );
                                      return false;
                                    }
                                    return true;
                                  default:
                                    return true;
                                }
                              }

                              return AlertDialog(
                                title: const Text('Post Invoice'),
                                content: SizedBox(
                                  width: 380,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: buildFields(),
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
                                      if (!validate()) return;
                                      Navigator.of(context).pop();
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Posted with: ${selected ?? '-'}'),
                                        ),
                                      );
                                    },
                                    child: const Text('Post'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    child: const Text('Post'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
