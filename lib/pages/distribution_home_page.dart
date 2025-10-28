import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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
      appBar: AppBar(
        title: const Text('Distribution - Ref Portal'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              // Invoice -> Sales dashboard
              buildCard(
                icon: Icons.request_quote_rounded,
                title: 'Invoice',
                onTap: () => Navigator.of(context).pushNamed('/invoices'),
                color: const Color(0xFF10B981),
              ),
              // Receipt
              buildCard(
                icon: Icons.receipt_long_rounded,
                title: 'Receipt',
                onTap: () => Navigator.of(context).pushNamed('/receipt'),
                color: const Color(0xFF6366F1),
              ),
              // Customer Creation
              buildCard(
                icon: Icons.person_add_alt_1_rounded,
                title: 'Customer Creation',
                onTap: () => Navigator.of(context).pushNamed('/customer-create'),
                color: const Color(0xFFF59E0B),
              ),
              // Customer Return
              buildCard(
                icon: Icons.assignment_return_rounded,
                title: 'Customer Return',
                onTap: () => Navigator.of(context).pushNamed('/customer-return'),
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
