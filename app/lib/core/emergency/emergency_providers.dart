import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/emergency_contact.dart';

// Storage keys
const String _emergencyContactsKey = 'emergency_contacts';
const String _userProfileKey = 'user_profile';

// Emergency Contacts Provider
class EmergencyContactsNotifier extends StateNotifier<List<EmergencyContact>> {
  EmergencyContactsNotifier() : super([]) {
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_emergencyContactsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      state = jsonList
          .map(
              (json) => EmergencyContact.fromJson(json as Map<String, dynamic>))
          .toList();
      // Sort by priority
      state.sort((a, b) => a.priority.compareTo(b.priority));
    }
  }

  Future<void> addContact(EmergencyContact contact) async {
    if (state.length >= 5) {
      throw Exception('Maximum 5 emergency contacts allowed');
    }
    state = [...state, contact];
    state.sort((a, b) => a.priority.compareTo(b.priority));
    await _saveContacts();
  }

  Future<void> updateContact(EmergencyContact contact) async {
    state = [
      for (final c in state)
        if (c.id == contact.id) contact else c,
    ];
    state.sort((a, b) => a.priority.compareTo(b.priority));
    await _saveContacts();
  }

  Future<void> deleteContact(String id) async {
    state = state.where((c) => c.id != id).toList();
    await _saveContacts();
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.map((c) => c.toJson()).toList());
    await prefs.setString(_emergencyContactsKey, jsonString);
  }

  EmergencyContact? get primaryContact {
    if (state.isEmpty) return null;
    return state.reduce((a, b) => a.priority < b.priority ? a : b);
  }

  bool get hasMinimumContacts => state.length >= 3;
}

final emergencyContactsProvider =
    StateNotifierProvider<EmergencyContactsNotifier, List<EmergencyContact>>(
  (ref) => EmergencyContactsNotifier(),
);

// User Profile Provider
class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userProfileKey);
    if (jsonString != null) {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      state = UserProfile.fromJson(jsonMap);
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = profile;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(profile.toJson());
    await prefs.setString(_userProfileKey, jsonString);
  }

  Future<void> setGender(Gender gender) async {
    if (state != null) {
      await updateProfile(state!.copyWith(gender: gender));
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>(
  (ref) => UserProfileNotifier(),
);

// Helper provider to check SOS access
final canAccessSOSProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.canAccessSOS ?? false;
});

// SOS Activation Log
class SOSActivation {
  final DateTime timestamp;
  final String contactCalled;
  final Map<String, dynamic>? metadata;

  SOSActivation({
    required this.timestamp,
    required this.contactCalled,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'contactCalled': contactCalled,
      'metadata': metadata,
    };
  }

  factory SOSActivation.fromJson(Map<String, dynamic> json) {
    return SOSActivation(
      timestamp: DateTime.parse(json['timestamp'] as String),
      contactCalled: json['contactCalled'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class SOSLogNotifier extends StateNotifier<List<SOSActivation>> {
  SOSLogNotifier() : super([]) {
    _loadLog();
  }

  Future<void> _loadLog() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('sos_log');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      state = jsonList
          .map((json) => SOSActivation.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> logActivation(String contactCalled,
      {Map<String, dynamic>? metadata}) async {
    final activation = SOSActivation(
      timestamp: DateTime.now(),
      contactCalled: contactCalled,
      metadata: metadata,
    );
    state = [...state, activation];
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.map((a) => a.toJson()).toList());
    await prefs.setString('sos_log', jsonString);
  }
}

final sosLogProvider =
    StateNotifierProvider<SOSLogNotifier, List<SOSActivation>>(
  (ref) => SOSLogNotifier(),
);
