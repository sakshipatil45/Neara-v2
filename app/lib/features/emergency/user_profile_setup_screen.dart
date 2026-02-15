import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/emergency_contact.dart';
import '../../core/emergency/emergency_providers.dart';
import '../../core/theme/app_theme.dart';

class UserProfileSetupScreen extends ConsumerStatefulWidget {
  const UserProfileSetupScreen({super.key});

  @override
  ConsumerState<UserProfileSetupScreen> createState() =>
      _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState
    extends ConsumerState<UserProfileSetupScreen> {
  final _nameController = TextEditingController();
  Gender _selectedGender = Gender.preferNotToSay;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    if (profile != null) {
      _nameController.text = profile.name;
      _selectedGender = profile.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile Setup',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            ...Gender.values.map((gender) {
              return RadioListTile<Gender>(
                value: gender,
                groupValue: _selectedGender,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGender = value;
                    });
                  }
                },
                title: Text(_getGenderLabel(gender)),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            }),
            const SizedBox(height: 16),
            if (_selectedGender == Gender.female)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD97706),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Emergency SOS feature will be available to you',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppGradients.accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGenderLabel(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }

  void _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    final profile = UserProfile(
      userId: 'user_1', // In real app, use actual user ID
      name: _nameController.text,
      gender: _selectedGender,
    );

    await ref.read(userProfileProvider.notifier).updateProfile(profile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
      Navigator.pop(context);
    }
  }
}
