import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/cart_provider.dart';

class InvoiceSimplePage extends StatefulWidget {
  const InvoiceSimplePage({super.key});

  @override
  State<InvoiceSimplePage> createState() => _InvoiceSimplePageState();
}

class _CustomerSelectionDialog extends StatefulWidget {
  const _CustomerSelectionDialog({required this.customers});

  final List<Map<String, String>> customers;

  @override
  State<_CustomerSelectionDialog> createState() =>
      _CustomerSelectionDialogState();
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
        return code.contains(lowerQuery) ||
            name.contains(lowerQuery) ||
            phone.contains(lowerQuery);
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
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            foregroundColor:
                                theme.colorScheme.onSecondaryContainer,
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
      'customer': 'Sun Plastics',
      'date': '12 Aug 2024',
      'amount': 'Rs. 32,500.00',
    },
    {
      'id': 'QT-1005',
      'customer': 'Green Polywares',
      'date': '03 Sep 2024',
      'amount': 'Rs. 18,200.00',
    },
    {
      'id': 'QT-1010',
      'customer': 'Sun Plastics',
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
      'customer': 'Green Polywares',
      'date': '08 Oct 2024',
      'amount': 'Rs. 56,780.00',
    },
    {
      'id': 'SO-2312',
      'customer': 'Sun Plastics',
      'date': '11 Oct 2024',
      'amount': 'Rs. 24,990.00',
    },
    {
      'id': 'SO-2320',
      'customer': 'Green Polywares',
      'date': '18 Oct 2024',
      'amount': 'Rs. 87,400.00',
    },
  ];

  List<Map<String, String>> get _filteredQuotations => _selectedCustomer != null
      ? _mockQuotations
            .where((q) => q['customer'] == _selectedCustomer!['name'])
            .toList()
      : [];

  List<Map<String, String>> get _filteredSalesOrders =>
      _selectedCustomer != null
      ? _mockSalesOrders
            .where((so) => so['customer'] == _selectedCustomer!['name'])
            .toList()
      : [];

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
      return const _DiscountValidationResult(
        errorMessage: 'Select an item first.',
      );
    }

    final quantity = int.tryParse(quantityText.trim());
    if (quantity == null || quantity <= 0) {
      return const _DiscountValidationResult(
        errorMessage: 'Quantity must be above zero.',
      );
    }

    final freeQuantity = int.tryParse(
      freeQuantityText.trim().isEmpty ? '0' : freeQuantityText.trim(),
    );
    if (freeQuantity == null || freeQuantity < 0) {
      return const _DiscountValidationResult(
        errorMessage: 'Enter a valid free quantity.',
      );
    }

    final discountValue = double.tryParse(
      discountText.trim().isEmpty ? '0' : discountText.trim(),
    );
    if (discountValue == null || discountValue < 0) {
      return const _DiscountValidationResult(
        errorMessage: 'Enter a valid discount.',
      );
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

    final summary =
        '${useAmountDiscount ? 'Flat' : 'Percent'} discount • Net Rs ${finalPrice.toStringAsFixed(2)}';

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
      builder: (dialogContext) =>
          _CustomerSelectionDialog(customers: _mockCustomers),
    );
  }

  Future<void> _openPostInvoiceDialog() async {
    // Define payment methods as a list of maps with proper typing
    final List<Map<String, dynamic>> paymentMethods = [
      {'id': 'cash', 'name': 'Cash', 'requiresDetails': false},
      {'id': 'cheque', 'name': 'Cheque', 'requiresDetails': true},
      {'id': 'card', 'name': 'Credit/Debit Card', 'requiresDetails': true},
      {'id': 'bank_transfer', 'name': 'Bank Transfer', 'requiresDetails': true},
    ];

    // Initialize selected payment method for each row with proper typing
    final List<String> selectedPaymentMethods = List<String>.filled(
      _rows.length,
      paymentMethods.first['id'] as String, // Default to first payment method
    );

    final amountController = TextEditingController();
    final detailsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Check if there are any items to display
    if (_rows.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add items to the invoice before posting'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Set default amount to the invoice total if available
    final total = _calculateSubTotal();
    if (total > 0) {
      amountController.text = total.toStringAsFixed(2);
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Post Invoice'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Items table header
                      const Text(
                        'Select Payment Method for Each Item:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Items table with fixed height and scrollable content
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _rows.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('No items in the invoice'),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(3),
                                  },
                                  border: TableBorder.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  children: [
                                    // Table header
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                      ),
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'Item',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'Payment Method',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Table rows
                                    ...List.generate(_rows.length, (index) {
                                      final item = _rows[index];
                                      return TableRow(
                                        decoration: BoxDecoration(
                                          color: index.isOdd
                                              ? Colors.grey.shade50
                                              : Colors.white,
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              '${item['name']} x${item['quantity']}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButtonFormField<String>(
                                                value:
                                                    selectedPaymentMethods[index],
                                                isExpanded: true,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                items: paymentMethods
                                                    .map<
                                                      DropdownMenuItem<String>
                                                    >((method) {
                                                      return DropdownMenuItem<
                                                        String
                                                      >(
                                                        value:
                                                            method['id']
                                                                as String,
                                                        child: Text(
                                                          method['name']
                                                              as String,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13,
                                                              ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      );
                                                    })
                                                    .toList(),
                                                onChanged: (String? value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      selectedPaymentMethods[index] =
                                                          value;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                      ),

                      const SizedBox(height: 16),

                      // Payment amount
                      TextFormField(
                        controller: amountController,
                        decoration: const InputDecoration(
                          labelText: 'Total Amount',
                          border: OutlineInputBorder(),
                          prefixText: 'Rs. ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Payment details (shown when a method requiring details is selected)
                      if (selectedPaymentMethods.any(
                        (method) =>
                            paymentMethods.firstWhere(
                              (m) => m['id'] == method,
                            )['requiresDetails'] ==
                            true,
                      ))
                        TextFormField(
                          controller: detailsController,
                          decoration: const InputDecoration(
                            labelText: 'Payment Details',
                            border: OutlineInputBorder(),
                            hintText: 'Enter payment reference or details',
                          ),
                          maxLines: 2,
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      // Process the payment with all selected methods
                      _processPayment(
                        selectedPaymentMethods,
                        amountController.text,
                        detailsController.text,
                      );

                      // Clear the form after successful submission
                      _rows.clear();

                      // Show success message
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invoice posted successfully!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }

                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('CONFIRM PAYMENT'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Process payment when the confirm button is pressed
  void _processPayment(
    List<String> paymentMethods,
    String amount,
    String details,
  ) {
    debugPrint('Processing payment for ${_rows.length} items');
    for (int i = 0; i < _rows.length; i++) {
      debugPrint('Item ${i + 1}: ${_rows[i]['name']} - ${paymentMethods[i]}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment processed: Rs. $amount'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
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
              final tempController = TextEditingController(
                text: controller.text,
              );
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
                          ? [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                            ]
                          : [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pop(tempController.text.trim()),
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
                  controller.text = parsed == null
                      ? fallback
                      : parsed.toString();
                } else {
                  final parsed = int.tryParse(value);
                  controller.text = parsed == null
                      ? fallback
                      : parsed.toString();
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
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final item = filteredItems[index];
                                      final isSelected =
                                          selectedItem != null &&
                                          selectedItem!['code'] == item['code'];
                                      return ListTile(
                                        selected: isSelected,
                                        selectedTileColor: theme
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor: theme
                                              .colorScheme
                                              .primaryContainer,
                                          foregroundColor: theme
                                              .colorScheme
                                              .onPrimaryContainer,
                                          child: Text(
                                            (item['code'] as String).substring(
                                              0,
                                              2,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          '${item['code']} • ${item['name']}',
                                        ),
                                        subtitle: Text(
                                          'Rs ${(item['price'] as num).toStringAsFixed(2)} per ${item['uom']}',
                                        ),
                                        onTap: () {
                                          setDialogState(() {
                                            selectedItem = item;
                                            searchController.text =
                                                item['name'] as String;
                                            filteredItems = _mockItems
                                                .where(
                                                  (element) => matchesQuery(
                                                    element,
                                                    searchController.text,
                                                  ),
                                                )
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
                                final quantity = int.tryParse(
                                  qtyController.text.trim(),
                                );
                                final freeQty = int.tryParse(
                                  freeQtyController.text.trim(),
                                );
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
                                  final unitPrice =
                                      (selectedItem!['price'] as num)
                                          .toDouble();
                                  final totalPrice = unitPrice * quantity;

                                  if (discountValue != null) {
                                    double convertedValue;
                                    if (useAmountDiscount) {
                                      convertedValue =
                                          totalPrice * (discountValue / 100);
                                    } else {
                                      convertedValue = totalPrice == 0
                                          ? 0
                                          : (discountValue / totalPrice) * 100;
                                    }

                                    discountController.text =
                                        convertedValue.isFinite
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
                                child: Center(
                                  child: Text('No items added yet'),
                                ),
                              )
                            : ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 220,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
                                    columnSpacing: 12,
                                    dataRowMinHeight: 44,
                                    columns: const [
                                      DataColumn(label: Text('Item')),
                                      DataColumn(
                                        label: Text('Qty'),
                                        numeric: true,
                                      ),
                                      DataColumn(
                                        label: Text('Free'),
                                        numeric: true,
                                      ),
                                      DataColumn(label: Text('Disc')),
                                      DataColumn(
                                        label: Text('Net'),
                                        numeric: true,
                                      ),
                                      DataColumn(label: Text('')),
                                    ],
                                    rows: pendingEntries
                                        .asMap()
                                        .entries
                                        .map(
                                          (entry) => DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  _shortItemLabel(
                                                    entry.value['item']
                                                            as String? ??
                                                        '',
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              DataCell(
                                                Text('${entry.value['qty']}'),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${entry.value['freeQty']}',
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${entry.value['discount']}',
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  'Rs ${(entry.value['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                                ),
                                              ),
                                              DataCell(
                                                IconButton(
                                                  tooltip: 'Remove',
                                                  icon: const Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                  ),
                                                  onPressed: () {
                                                    setDialogState(() {
                                                      pendingEntries.removeAt(
                                                        entry.key,
                                                      );
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
                          backgroundColor: theme.colorScheme.error.withOpacity(
                            0.12,
                          ),
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
                              errorText =
                                  'Add at least one entry before confirming.';
                            });
                            return;
                          }

                          Navigator.of(dialogContext).pop({
                            'rows': pendingEntries
                                .map((e) => Map<String, dynamic>.from(e))
                                .toList(),
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
    return _rows.fold<double>(
      0,
      (sum, row) => sum + ((row['price'] as num?)?.toDouble() ?? 0.0),
    );
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
              Text(
                'Sales Order: $salesOrder',
                style: theme.textTheme.bodyMedium,
              ),
              const Divider(height: 24),
              Text('Items: ${_rows.length}', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                'Subtotal: Rs ${subtotal.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium,
              ),
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
    if (data.isEmpty) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No records available for selected customer'),
        ),
      );
      return null;
    }
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
                    child: Center(child: Text('No records available')),
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
              onPressed: () =>
                  Navigator.of(dialogContext).pop(<String, String>{}),
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
    String? selectedTax;
    bool isPercentageDiscount = true;

    // List of available tax options
    final List<String> taxOptions = [
      'NBT 1 & VAT',
      'NBT 2 & VAT',
      'VAT',
      'NBT, VAT',
      'NBT 1, VAT',
    ];

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: const Text('Discount & Taxes'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Discount Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: discountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText:
                                'Discount ${isPercentageDiscount ? '(%)' : '(Rs)'}',
                            border: const OutlineInputBorder(),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                '%',
                                style: TextStyle(
                                  color: isPercentageDiscount
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withOpacity(
                                          0.5,
                                        ),
                                  fontWeight: isPercentageDiscount
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            Switch.adaptive(
                              value: isPercentageDiscount,
                              onChanged: (value) {
                                setState(() => isPercentageDiscount = value);
                              },
                              activeColor: theme.colorScheme.primary,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                'Rs',
                                style: TextStyle(
                                  color: !isPercentageDiscount
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withOpacity(
                                          0.5,
                                        ),
                                  fontWeight: !isPercentageDiscount
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tax Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedTax,
                    decoration: const InputDecoration(
                      labelText: 'Select Tax Type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      isDense: true,
                    ),
                    items: taxOptions.map((String tax) {
                      return DropdownMenuItem<String>(
                        value: tax,
                        child: Text(tax),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedTax = value;
                      });
                    },
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
                    final discount = discountCtrl.text.trim().isEmpty
                        ? 0.0
                        : double.tryParse(discountCtrl.text.trim()) ?? 0.0;
                    final discountType = isPercentageDiscount ? '%' : 'Rs';
                    final taxType = selectedTax ?? 'No Tax Selected';

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Discount: $discount$discountType • Tax: $taxType',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
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
                      final displayLabel =
                          _selectedCustomer?['name'] ??
                          customerName ??
                          'Select Customer';
                      return ElevatedButton.icon(
                        onPressed: () async {
                          final selection = await _showCustomerDialog();
                          if (!mounted || selection == null) return;
                          setState(() {
                            if (selection.isEmpty) {
                              _selectedCustomer = null;
                              _selectedQuotation = null;
                              _selectedSalesOrder = null;
                              cart.setCustomerInfo(name: null);
                            } else {
                              _selectedCustomer = selection;
                              // Clear previous selections when customer changes
                              _selectedQuotation = null;
                              _selectedSalesOrder = null;
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
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 8,
                          ),
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
                    onPressed: _selectedCustomer == null
                        ? null
                        : () async {
                            final selection = await _showMockDataDialog(
                              title:
                                  'Quotations for ${_selectedCustomer!['name']}',
                              data: _filteredQuotations,
                              icon: Icons.description_rounded,
                            );
                            if (!mounted) return;
                            setState(() {
                              if (selection == null) return;
                              _selectedQuotation = selection.isEmpty
                                  ? null
                                  : selection;
                            });
                          },
                    icon: const Icon(Icons.description_rounded),
                    label: Text(
                      _selectedQuotation?['id'] ?? 'Quotations',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedCustomer == null
                        ? null
                        : () async {
                            final selection = await _showMockDataDialog(
                              title:
                                  'Sales Orders for ${_selectedCustomer!['name']}',
                              data: _filteredSalesOrders,
                              icon: Icons.shopping_cart_rounded,
                            );
                            if (!mounted) return;
                            setState(() {
                              if (selection == null) return;
                              _selectedSalesOrder = selection.isEmpty
                                  ? null
                                  : selection;
                            });
                          },
                    icon: const Icon(Icons.shopping_cart_rounded),
                    label: Text(
                      _selectedSalesOrder?['id'] ?? 'Sales Order',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
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
                        const DataColumn(label: Text('Item'), numeric: false),
                        const DataColumn(label: Text('Qty'), numeric: true),
                        const DataColumn(label: Text('Free'), numeric: true),
                        const DataColumn(
                          label: Text('Discount'),
                          numeric: true,
                        ),
                        const DataColumn(label: Text('Price'), numeric: true),
                        const DataColumn(
                          label: SizedBox(
                            width: 60,
                            child: Center(child: Text('Action')),
                          ),
                          numeric: false,
                          tooltip: 'Remove item',
                        ),
                      ],
                      rows: _rows.asMap().entries.map((entry) {
                        final index = entry.key;
                        final r = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                _shortItemLabel(r['item'] as String?),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Text('${r['qty']}', textAlign: TextAlign.end),
                            ),
                            DataCell(
                              Text(
                                '${r['freeQty'] ?? 0}',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            DataCell(
                              Text(
                                '${r['discount']}',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            DataCell(
                              Text('${r['price']}', textAlign: TextAlign.end),
                            ),
                            DataCell(
                              Container(
                                width: 60,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _rows.removeAt(index);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Item removed'),
                                        behavior: SnackBarBehavior.floating,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(8),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.errorContainer,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
