import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/emergency/emergency_providers.dart';
import '../../core/emergency/location_sharing_service.dart';
import '../../core/ai/ai_providers.dart';
import 'emergency_contacts_screen.dart';

class SafetySettingsScreen extends ConsumerWidget {
  const SafetySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    final contacts = ref.watch(emergencyContactsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Safety Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Safety Mode Section
            _buildSectionHeader('Smart Safety'),
            const SizedBox(height: 12),
            _SafetyModeToggle(
              value: filters.womenSafetyMode,
              onChanged: (value) {
                ref.read(searchFiltersProvider.notifier).update(
                      filters.copyWith(womenSafetyMode: value),
                    );
              },
            ),
            const SizedBox(height: 24),

            // Emergency Contacts Section
            _buildSectionHeader('Support Network'),
            const SizedBox(height: 12),
            _SafetyActionCard(
              title: 'Emergency Contacts',
              subtitle: contacts.isEmpty
                  ? 'Add 3-5 contacts for SOS'
                  : '${contacts.length} contacts configured',
              icon: Icons.people_alt_rounded,
              iconColor: const Color(0xFF3B82F6),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: contacts.length >= 3
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  contacts.length >= 3 ? 'READY' : 'INCOMPLETE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: contacts.length >= 3
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyContactsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Advanced Protection Section
            _buildSectionHeader('Advanced Protection'),
            const SizedBox(height: 12),
            _SafetyActionCard(
              title: 'Live Session Tracking',
              subtitle: 'Share live location during service',
              icon: Icons.location_searching_rounded,
              iconColor: const Color(0xFF10B981),
              enabled: filters.womenSafetyMode,
              trailing: Switch(
                value: filters.liveTracking,
                onChanged: filters.womenSafetyMode
                    ? (value) {
                        ref.read(searchFiltersProvider.notifier).update(
                              filters.copyWith(liveTracking: value),
                            );
                      }
                    : null,
                activeColor: const Color(0xFF10B981),
              ),
              onTap: filters.womenSafetyMode
                  ? () => _showFeatureExplainer(
                        context,
                        'Live Session Tracking',
                        'Keep your loved ones informed with real-time location sharing during active services. \n\n• Automatic updates to emergency contacts\n• One-tap sharing during sessions\n• Instant SOS context mapping',
                        Icons.location_searching_rounded,
                        const Color(0xFF10B981),
                      )
                  : null,
            ),
            if (filters.liveTracking &&
                ref.watch(emergencyContactsProvider.notifier).primaryContact !=
                    null) ...[
              const SizedBox(height: 8),
              Opacity(
                opacity: filters.womenSafetyMode ? 1.0 : 0.5,
                child: IgnorePointer(
                  ignoring: !filters.womenSafetyMode,
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFF59E0B), size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Share with Prioritized Contact',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                'Forward updates to ${ref.watch(emergencyContactsProvider.notifier).primaryContact?.name}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: filters.womenSafetyMode
                                    ? () async {
                                        final contact = ref
                                            .read(emergencyContactsProvider
                                                .notifier)
                                            .primaryContact;
                                        if (contact != null) {
                                          try {
                                            await LocationSharingService
                                                .shareLocationWithContact(
                                                    contact);
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to share: $e')),
                                            );
                                          }
                                        }
                                      }
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: const Color(0xFFF59E0B)
                                            .withOpacity(0.2)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.share_location_rounded,
                                          color: Color(0xFFF59E0B), size: 14),
                                      SizedBox(width: 6),
                                      Text(
                                        'SHARE NOW',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFF59E0B),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: filters.shareWithPrioritized,
                            onChanged: filters.womenSafetyMode
                                ? (value) {
                                    ref
                                        .read(searchFiltersProvider.notifier)
                                        .update(
                                          filters.copyWith(
                                              shareWithPrioritized: value),
                                        );
                                  }
                                : null,
                            activeColor: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _SafetyActionCard(
              title: 'AI Risk Monitoring',
              subtitle: 'Auto-flag suspicious patterns',
              icon: Icons.psychology_rounded,
              iconColor: const Color(0xFF6366F1),
              enabled: filters.womenSafetyMode,
              trailing: Switch(
                value: filters.riskMonitoring,
                onChanged: filters.womenSafetyMode
                    ? (value) {
                        ref.read(searchFiltersProvider.notifier).update(
                              filters.copyWith(riskMonitoring: value),
                            );
                      }
                    : null,
                activeColor: const Color(0xFF6366F1),
              ),
              onTap: filters.womenSafetyMode
                  ? () => _showFeatureExplainer(
                        context,
                        'AI Risk Monitoring',
                        'Advanced AI patterns monitor local activity to keep you ahead of potential risks. \n\n• Anomaly detection in worker behaviors\n• Real-time safe-zone verification\n• Instant advisory for high-risk areas',
                        Icons.psychology_rounded,
                        const Color(0xFF6366F1),
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureExplainer(BuildContext context, String title,
      String description, IconData icon, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'GOT IT',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: Color(0xFF64748B),
        letterSpacing: 1.0,
      ),
    );
  }
}

class _SafetyModeToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SafetyModeToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: value ? const Color(0xFFFEF3C7) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value ? const Color(0xFFD97706) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: value
                ? const Color(0xFFD97706).withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      value ? const Color(0xFFD97706) : const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Women Safety Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value ? 'ENABLED' : 'DISABLED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: value
                            ? const Color(0xFF92400E)
                            : const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFFD97706),
                activeTrackColor: const Color(0xFFFCD34D),
              ),
            ],
          ),
          if (value) ...[],
        ],
      ),
    );
  }
}

class _SafetyActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;
  final bool enabled;
  final VoidCallback? onTap;

  const _SafetyActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.trailing,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
