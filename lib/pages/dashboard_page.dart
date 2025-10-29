import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // No animations needed

  @override
  void initState() {
    super.initState();
    //
  }

  @override
  void dispose() {
    //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildCard({
      required IconData icon,
      required String title,
      String? subtitle,
      required VoidCallback onTap,
      Color color = const Color(0xFF6366F1),
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
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
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false);
          },
        ),
        title: const Text('Distribution - Ref Portal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 1100 ? 4 : width >= 800 ? 3 : 2;
            final aspect = width >= 1100 ? 1.2 : width >= 800 ? 1.15 : 1.1;
            return GridView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: aspect,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return buildCard(
                      icon: Icons.shopping_cart_rounded,
                      title: 'Sales Order',
                      subtitle: 'Create customer orders',
                      onTap: () => Navigator.of(context).pushNamed('/sales-order'),
                      color: const Color(0xFF6366F1),
                    );
                  case 1:
                    return buildCard(
                      icon: Icons.request_quote_rounded,
                      title: 'Invoice',
                      subtitle: 'Create and manage invoices',
                      onTap: () => Navigator.of(context).pushNamed('/invoices'),
                      color: const Color(0xFF10B981),
                    );
                  case 2:
                    return buildCard(
                      icon: Icons.description_rounded,
                      title: 'Quotation',
                      subtitle: 'Prepare price quotes',
                      onTap: () => Navigator.of(context).pushNamed('/quotation'),
                      color: const Color(0xFF22C55E),
                    );
                  case 3:
                    return buildCard(
                      icon: Icons.assignment_return_rounded,
                      title: 'CRN (Customer Return Note)',
                      subtitle: 'Process sales returns',
                      onTap: () => Navigator.of(context).pushNamed('/customer-return'),
                      color: const Color(0xFFEF4444),
                    );
                  case 4:
                    return buildCard(
                      icon: Icons.receipt_long_rounded,
                      title: 'Receipts',
                      subtitle: 'Record customer payments',
                      onTap: () => Navigator.of(context).pushNamed('/receipt'),
                      color: const Color(0xFF6366F1),
                    );
                  case 5:
                    return buildCard(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Customer Registration',
                      subtitle: 'Onboard new customers',
                      onTap: () => Navigator.of(context).pushNamed('/customer-create'),
                      color: const Color(0xFFF59E0B),
                    );
                  case 6:
                    return buildCard(
                      icon: Icons.bar_chart_rounded,
                      title: 'Stock Reports',
                      subtitle: 'View stock availability',
                      onTap: () => Navigator.of(context).pushNamed('/stock-reports'),
                      color: const Color(0xFF0EA5E9),
                    );
                  default:
                    return buildCard(
                      icon: Icons.payments_rounded,
                      title: 'My Sales & to be Collected',
                      subtitle: 'Track sales and collections',
                      onTap: () => Navigator.of(context).pushNamed('/my-sales'),
                      color: const Color(0xFF8B5CF6),
                    );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
