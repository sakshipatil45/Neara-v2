import '../../../core/ai/gemini_service.dart';

enum WorkerStatus { available, busy, off }

enum VerificationLevel {
  basic,
  intermediate,
  governmentId,
  fullyBackgroundChecked
}

enum Gender { male, female, other }

class Worker {
  final String id;
  final String name;
  final ServiceCategory primaryCategory;
  final List<String> skills;
  final double rating;
  final int jobCount;
  final bool verified;
  final VerificationLevel verificationLevel;
  final Gender gender;
  final double latitude;
  final double longitude;
  final WorkerStatus status;
  final double riskScore; // 0.0 to 1.0, where 0 is safest

  Worker({
    required this.id,
    required this.name,
    required this.primaryCategory,
    required this.skills,
    required this.rating,
    required this.jobCount,
    required this.verified,
    this.verificationLevel = VerificationLevel.basic,
    required this.gender,
    required this.latitude,
    required this.longitude,
    this.status = WorkerStatus.available,
    this.riskScore = 0.0,
  });
}
