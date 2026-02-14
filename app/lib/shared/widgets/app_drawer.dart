import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final void Function(int index)? onSelectScreen;

  const AppDrawer({super.key, this.onSelectScreen});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DrawerHeader(),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () {
                Navigator.of(context).maybePop();
                onSelectScreen?.call(0);
              },
            ),
            _DrawerItem(
              icon: Icons.search_rounded,
              label: 'Browse Services',
              onTap: () {
                Navigator.of(context).maybePop();
                onSelectScreen?.call(1);
              },
            ),
            _DrawerItem(
              icon: Icons.language_rounded,
              label: 'Multilingual AI Demo',
              onTap: () {
                Navigator.of(context).maybePop();
                onSelectScreen?.call(2);
              },
            ),
            const _DrawerItem(
              icon: Icons.bookmark_rounded,
              label: 'Saved Workers',
            ),
            const _DrawerItem(
              icon: Icons.assignment_rounded,
              label: 'My Requests',
            ),
            const _DrawerItem(
              icon: Icons.shield_rounded,
              label: 'Safety & SOS',
            ),
            const Spacer(),
            const Divider(height: 1),
            const _DrawerItem(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
            ),
            const _DrawerItem(icon: Icons.settings_rounded, label: 'Settings'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF000000), Color(0xFF111827)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Neara',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Emergency-ready discovery',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DrawerItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            onTap ??
            () {
              Navigator.of(context).maybePop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$label - Coming soon!')));
            },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
