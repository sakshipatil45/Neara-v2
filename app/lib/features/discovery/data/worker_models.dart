import '../../../core/enums/service_category.dart';

enum WorkerStatus { available, busy, off }

class Worker {
  final String id;
  final String name;
  final ServiceCategory primaryCategory;
  final List<String> skills;
  final double rating;
  final int jobCount;
  final bool verified;
  final double latitude;
  final double longitude;
  final WorkerStatus status;

  final int responseTimeMinutes;

  Worker({
    required this.id,
    required this.name,
    required this.primaryCategory,
    required this.skills,
    required this.rating,
    required this.jobCount,
    required this.verified,
    required this.latitude,
    required this.longitude,
    this.status = WorkerStatus.available,
    this.responseTimeMinutes = 30,
  });
}
