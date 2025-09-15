import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("About"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo + Title
          Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  LucideIcons.shoppingBag,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Cartelle",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Your smart shopping companion",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),

          // About this app
          _InfoCard(
            icon: LucideIcons.info,
            title: "About This App",
            description:
                "Helps you manage shopping lists, reminders, and spending analytics, all in one simple, elegant place.",
          ),

          const SizedBox(height: 12),

          // Features
          _InfoCard(
            icon: LucideIcons.star,
            title: "Features",
            description:
                "• Location-based reminders\n"
                "• Smart shopping lists\n"
                "• Spending analytics\n"
                "• Clean, elegant design",
          ),

          const SizedBox(height: 12),

          // Privacy
          _InfoCard(
            icon: LucideIcons.lock,
            title: "Privacy",
            description:
                "Your data is stored securely. We never sell your information. You stay in control.",
          ),

          const SizedBox(height: 12),

          // Developer
          _InfoCard(
            icon: LucideIcons.user,
            title: "Developer",
            description: "Made with ❤️ by Rishi Sharma",
          ),

          const SizedBox(height: 20),

          // Version + Contact
          Center(
            child: Column(
              children: [
                Text(
                  "Version 1.0.0",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "📧 rishi.2030s@gmail.com",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
