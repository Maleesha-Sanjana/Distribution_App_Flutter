import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildCard({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
      Color color = const Color(0xFF6366F1),
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final menuItems = [
      {
        'icon': Icons.shopping_cart_rounded,
        'title': 'Sales Order',
        'route': '/sales-order',
        'color': const Color(0xFF6366F1),
      },
      {
        'icon': Icons.request_quote_rounded,
        'title': 'Invoice',
        'route': '/invoices',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.description_rounded,
        'title': 'Quotation',
        'route': '/quotation',
        'color': const Color(0xFF22C55E),
      },
      {
        'icon': Icons.assignment_return_rounded,
        'title': 'CRN (Customer Return)',
        'route': '/sales-return',
        'color': const Color(0xFFEF4444),
      },
      {
        'icon': Icons.receipt_long_rounded,
        'title': 'Receipts',
        'route': '/receipt',
        'color': const Color(0xFF6366F1),
      },
      {
        'icon': Icons.person_add_alt_1_rounded,
        'title': 'Customer Registration',
        'route': '/customer-create',
        'color': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.bar_chart_rounded,
        'title': 'Stock Reports',
        'route': '/stock-reports',
        'color': const Color(0xFF0EA5E9),
      },
      {
        'icon': Icons.payments_rounded,
        'title': 'My Sales & Outstanding',
        'route': '/my-sales',
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.onSurface,
          tooltip: 'Back to Login',
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          },
        ),
        title: const Text('Distribution - Ref Portal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 1100
                ? 4
                : width >= 800
                    ? 3
                    : 2;
            const spacing = 16.0;

            return GridView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: 1,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return buildCard(
                  icon: item['icon'] as IconData,
                  title: item['title'] as String,
                  onTap: () => Navigator.of(context).pushNamed(item['route'] as String),
                  color: item['color'] as Color,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
