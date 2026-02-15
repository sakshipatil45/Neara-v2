import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/emergency_contact.dart';
import '../../../core/emergency/emergency_providers.dart';
import '../../../core/theme/app_theme.dart';

class EmergencyContactsScreen extends ConsumerStatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  ConsumerState<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends ConsumerState<EmergencyContactsScreen> {
  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(emergencyContactsProvider);
    final hasMinimum = contacts.length >= 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Info Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasMinimum
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasMinimum
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFD97706),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasMinimum ? Icons.check_circle : Icons.info,
                  color: hasMinimum
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFD97706),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasMinimum
                        ? 'You have ${contacts.length} emergency contacts'
                        : 'Add at least 3 emergency contacts (max 5)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasMinimum
                          ? const Color(0xFF166534)
                          : const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contacts List
          Expanded(
            child: contacts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.contacts_rounded,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No emergency contacts yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add contacts who will be called in emergencies',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return _ContactCard(
                        key: ValueKey(contact.id),
                        contact: contact,
                        onEdit: () => _showContactDialog(contact),
                        onDelete: () => _deleteContact(contact.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: contacts.length < 5
          ? FloatingActionButton.extended(
              onPressed: () => _showContactDialog(null),
              backgroundColor: const Color(0xFF6366F1),
              icon: const Icon(Icons.add),
              label: const Text('Add Contact'),
            )
          : null,
    );
  }

  void _showContactDialog(EmergencyContact? contact) {
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController =
        TextEditingController(text: contact?.phoneNumber ?? '');
    int? priority = contact?.priority;

    final formKey = GlobalKey<FormState>();
    int? localPriority = priority;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Re-calculate available priorities inside the builder to ensure up-to-date state
          final usedPriorities = ref
              .watch(emergencyContactsProvider)
              .where((c) => c.id != contact?.id)
              .map((c) => c.priority)
              .toSet();

          final availablePriorities = [1, 2, 3, 4, 5].where((p) {
            return !usedPriorities.contains(p);
          }).toList();

          // Initialize localPriority if it's still null and we have options
          if (localPriority == null && availablePriorities.isNotEmpty) {
            localPriority = availablePriorities.first;
          } else if (localPriority != null &&
              !availablePriorities.contains(localPriority)) {
            // If the current priority is no longer available (shouldn't happen with the fix),
            // reset to the first available one
            localPriority = availablePriorities.isNotEmpty
                ? availablePriorities.first
                : null;
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(contact == null ? 'Add Contact' : 'Edit Contact',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      hintText: '+91 9876543210',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final regex = RegExp(r'^\+?[0-9]{10,15}$');
                      if (!regex.hasMatch(value.replaceAll(' ', ''))) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: localPriority,
                    decoration: const InputDecoration(
                      labelText: 'Assign Priority',
                      prefixIcon: Icon(Icons.star_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    items: availablePriorities
                        .map((i) => DropdownMenuItem(
                              value: i,
                              child: Text('Priority $i'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => localPriority = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL',
                    style: TextStyle(color: Color(0xFF64748B))),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate() &&
                      localPriority != null) {
                    final newContact = EmergencyContact(
                      id: contact?.id ?? const Uuid().v4(),
                      name: nameController.text.trim(),
                      phoneNumber: phoneController.text.trim(),
                      priority: localPriority!,
                    );

                    if (contact == null) {
                      ref
                          .read(emergencyContactsProvider.notifier)
                          .addContact(newContact);
                    } else {
                      ref
                          .read(emergencyContactsProvider.notifier)
                          .updateContact(newContact);
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(contact == null ? 'ADD' : 'UPDATE'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteContact(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(emergencyContactsProvider.notifier).deleteContact(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactCard({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.accentGradient,
          ),
          child: Center(
            child: Text(
              '${contact.priority}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          contact.phoneNumber,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF6366F1)),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
