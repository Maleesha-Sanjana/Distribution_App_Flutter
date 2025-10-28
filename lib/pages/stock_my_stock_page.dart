import 'package:flutter/material.dart';

class MyStockPage extends StatefulWidget {
  const MyStockPage({super.key});

  @override
  State<MyStockPage> createState() => _MyStockPageState();
}

class _MyStockPageState extends State<MyStockPage> {
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> _items = [
    {'name': 'Product 1', 'qty': 25},
    {'name': 'Product 2', 'qty': 0},
    {'name': 'Product 3', 'qty': 7},
    {'name': 'Product 4', 'qty': 120},
    {'name': 'Product 5', 'qty': -3},
    {'name': 'Product 6', 'qty': 42},
    {'name': 'Product 7', 'qty': 15},
    {'name': 'Product 8', 'qty': 0},
    {'name': 'Product 9', 'qty': 2},
    {'name': 'Product 10', 'qty': 88},
  ];

  // View By selection and dependent lists
  String _viewBy = 'Product Wise';
  String? _chosenFilter; // Selected department/sub-dept/category/etc.
  bool _displayAll = false; // Display all toggle

  final List<String> _departments = const [
    'Beverages',
    'Snacks',
    'Household',
    'Dairy',
    'Bakery',
    'Frozen',
    'Produce',
    'Meat',
    'Health & Beauty',
    'Stationery',
  ];
  final List<String> _subDepartments = const [
    'Soft Drinks',
    'Chips',
    'Detergents',
    'Yogurt',
    'Bread',
    'Ice Cream',
    'Leafy Greens',
    'Poultry',
    'Shampoos',
    'Notebooks',
  ];
  final List<String> _categories = const [
    'Groceries',
    'Personal Care',
    'Electronics',
    'Home Care',
    'Baby Care',
    'Beverage',
    'Snacks',
    'Pharmacy',
    'Pets',
    'Toys',
  ];
  final List<String> _subCategories = const [
    'Soda',
    'Biscuits',
    'Shampoos',
    'Surface Cleaners',
    'Diapers',
    'Juices',
    'Nuts',
    'Vitamins',
    'Dog Food',
    'Puzzles',
  ];
  final List<String> _suppliers = const [
    'ABC Distributors',
    'Mega Supply',
    'Sunrise Traders',
    'Blue Ocean Imports',
    'Green Valley Foods',
    'Prime Wholesale',
    'Cityline Suppliers',
    'NorthStar Co.',
    'Pearl Distributors',
    'Unity Traders',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildAdaptiveSearch() {
    List<String> dataset;
    String label;
    switch (_viewBy) {
      case 'Department Wise':
        dataset = _departments;
        label = 'Search Departments';
        break;
      case 'Sub-Department Wise':
        dataset = _subDepartments;
        label = 'Search Sub Departments';
        break;
      case 'Category Wise':
        dataset = _categories;
        label = 'Search Categories';
        break;
      case 'Sub Category Wise':
        dataset = _subCategories;
        label = 'Search Sub Categories';
        break;
      case 'Supplier Wise':
        dataset = _suppliers;
        label = 'Search Suppliers';
        break;
      default:
        dataset = _items.map((e) => e['name'] as String).toList();
        label = 'Search Products';
    }

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue tev) {
        final q = tev.text.trim().toLowerCase();
        if (q.isEmpty) return const Iterable<String>.empty();
        return dataset.where((e) => e.toLowerCase().contains(q));
      },
      onSelected: (val) {
        _searchController.text = val;
        setState(() {});
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        // Keep the shared controller in sync
        controller.text = _searchController.text;
        controller.selection = _searchController.selection;
        controller.addListener(() {
          if (controller.text != _searchController.text) {
            _searchController.value = controller.value;
            setState(() {});
          }
        });
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.search),
          ),
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, minWidth: 280),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final opt = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(opt),
                    onTap: () => onSelected(opt),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showViewBy() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        Widget option(String label, IconData icon) => ListTile(
              leading: Icon(icon),
              title: Text(label),
              onTap: () {
                setState(() {
                  _viewBy = label;
                  _chosenFilter = null; // reset dependent selection
                });
                Navigator.pop(context);
              },
            );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'View By',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                option('Product Wise', Icons.inventory_2_rounded),
                option('Department Wise', Icons.apartment_rounded),
                option('Sub-Department Wise', Icons.account_tree_rounded),
                option('Category Wise', Icons.category_rounded),
                option('Sub Category Wise', Icons.dashboard_customize_rounded),
                option('Supplier Wise', Icons.local_shipping_rounded),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSelectionPicker(String title, List<String> options) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              ...options.map((e) => ListTile(
                    title: Text(e),
                    onTap: () {
                      setState(() => _chosenFilter = e);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: $e')),
                      );
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = _searchController.text.trim().toLowerCase();
    final filtered = _items.where((e) {
      final nameMatch = _viewBy == 'Product Wise'
          ? (q.isEmpty || (e['name'] as String).toLowerCase().contains(q))
          : true;
      final qty = e['qty'] as int;
      final stockMatch = _displayAll ? true : qty > 0;
      return nameMatch && stockMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showViewBy,
                    icon: const Icon(Icons.tune),
                    label: Text(
                      _viewBy,
                      textAlign: TextAlign.justify,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _viewBy == 'Product Wise'
                        ? null
                        : () {
                            switch (_viewBy) {
                              case 'Department Wise':
                                _showSelectionPicker('Main Departments', _departments);
                                break;
                              case 'Sub-Department Wise':
                                _showSelectionPicker('Sub Departments', _subDepartments);
                                break;
                              case 'Category Wise':
                                _showSelectionPicker('Main Categories', _categories);
                                break;
                              case 'Sub Category Wise':
                                _showSelectionPicker('Sub Categories', _subCategories);
                                break;
                              case 'Supplier Wise':
                                _showSelectionPicker('Main Suppliers', _suppliers);
                                break;
                            }
                          },
                    icon: const Icon(Icons.list_alt),
                    label: Text(() {
                      switch (_viewBy) {
                        case 'Department Wise':
                          return _chosenFilter == null ? 'Main Departments' : _chosenFilter!;
                        case 'Sub-Department Wise':
                          return _chosenFilter == null ? 'Sub Departments' : _chosenFilter!;
                        case 'Category Wise':
                          return _chosenFilter == null ? 'Main Categories' : _chosenFilter!;
                        case 'Sub Category Wise':
                          return _chosenFilter == null ? 'Sub Categories' : _chosenFilter!;
                        case 'Supplier Wise':
                          return _chosenFilter == null ? 'Main Suppliers' : _chosenFilter!;
                        default:
                          return 'Select';
                      }
                    }(), textAlign: TextAlign.justify),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Container
              (
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _displayAll,
                      visualDensity: VisualDensity.compact,
                      onChanged: (v) => setState(() => _displayAll = v ?? false),
                    ),
                    const SizedBox(width: 6),
                    const Text('Display All'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            _buildAdaptiveSearch(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final it = filtered[index];
                  final qty = it['qty'] as int;
                  final inStock = qty > 0;
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.15)),
                    ),
                    title: Text(it['name']),
                    subtitle: Text('Qty: $qty'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (inStock ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2)),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: (inStock ? const Color(0xFF34D399) : const Color(0xFFEF4444)).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        inStock ? 'In stock' : 'Out of stock',
                        style: TextStyle(
                          color: inStock ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
