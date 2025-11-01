import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
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
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.onSurface,
          tooltip: 'Back to Login',
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);
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
            final availableWidth = width - spacing * (crossAxisCount - 1);
            final itemWidth = availableWidth / crossAxisCount;

            // 🔹 Reduced target height (smaller boxes)
            final targetHeight = width >= 1100
                ? 220.0
                : width >= 800
                ? 200.0
                : 150.0;

            final aspect = itemWidth / targetHeight;

            return GridView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: aspect,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                // 🔹 Slightly smaller bottom-row cards
                double scaleFactor = (index >= 4) ? 0.9 : 1.0;

                return Transform.scale(
                  scale: scaleFactor,
                  child: buildCard(
                    icon: [
                      Icons.shopping_cart_rounded,
                      Icons.request_quote_rounded,
                      Icons.description_rounded,
                      Icons.assignment_return_rounded,
                      Icons.receipt_long_rounded,
                      Icons.person_add_alt_1_rounded,
                      Icons.bar_chart_rounded,
                      Icons.payments_rounded,
                    ][index],
                    title: [
                      'Sales Order',
                      'Invoice',
                      'Quotation',
                      'CRN (Customer Return)',
                      'Receipts',
                      'Customer Registration',
                      'Stock Reports',
                      'My Sales & Outstanding',
                    ][index],
                    onTap: () {
                      final routes = [
                        '/sales-order',
                        '/invoices',
                        '/quotation',
                        '/sales-return',
                        '/receipt',
                        '/customer-create',
                        '/stock-reports',
                        '/my-sales',
                      ];
                      Navigator.of(context).pushNamed(routes[index]);
                    },
                    color: [
                      const Color(0xFF6366F1),
                      const Color(0xFF10B981),
                      const Color(0xFF22C55E),
                      const Color(0xFFEF4444),
                      const Color(0xFF6366F1),
                      const Color(0xFFF59E0B),
                      const Color(0xFF0EA5E9),
                      const Color(0xFF8B5CF6),
                    ][index],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
