import 'package:flutter/material.dart';

class MySalesDashboardPage extends StatelessWidget {
  const MySalesDashboardPage({super.key});

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
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.onSurface,
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('My Sales & to be Collected'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 1100 ? 3 : width >= 800 ? 3 : 2;
            final aspect = width >= 1100 ? 1.2 : width >= 800 ? 1.15 : 1.1;
            return GridView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: aspect,
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return buildCard(
                      icon: Icons.request_quote_rounded,
                      title: 'My invoice',
                      subtitle: 'View my invoices',
                      onTap: () => Navigator.of(context).pushNamed('/my-invoice'),
                      color: const Color(0xFF10B981),
                    );
                  case 1:
                    return buildCard(
                      icon: Icons.assignment_return_rounded,
                      title: 'My Return',
                      subtitle: 'View my returns',
                      onTap: () => Navigator.of(context).pushNamed('/my-return'),
                      color: const Color(0xFFEF4444),
                    );
                  default:
                    return buildCard(
                      icon: Icons.payments_rounded,
                      title: 'To be Collected',
                      subtitle: 'Pending collections',
                      onTap: () => Navigator.of(context).pushNamed('/to-be-collected'),
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
