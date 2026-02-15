class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final int priority; // 1 = highest priority

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'priority': priority,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      priority: json['priority'] as int,
    );
  }

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    int? priority,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      priority: priority ?? this.priority,
    );
  }
}

enum Gender { male, female, other, preferNotToSay }

class UserProfile {
  final String userId;
  final String name;
  final Gender gender;
  final String? email;
  final String? phone;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.gender,
    this.email,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'gender': gender.name,
      'email': email,
      'phone': phone,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      name: json['name'] as String,
      gender: Gender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => Gender.preferNotToSay,
      ),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  UserProfile copyWith({
    String? userId,
    String? name,
    Gender? gender,
    String? email,
    String? phone,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  bool get canAccessSOS => gender == Gender.female;
}
