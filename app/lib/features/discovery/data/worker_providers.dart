import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/gemini_service.dart';
import '../../../core/ai/ai_providers.dart';
import '../../../core/emergency/emergency_providers.dart';
import 'worker_models.dart';

final workersProvider = Provider<List<Worker>>((ref) {
  // TODO: Replace with Firestore-backed repository.
  return [
    Worker(
      id: '1',
      name: 'Sanjay Patil',
      primaryCategory: ServiceCategory.plumber,
      skills: const ['Leak repair', 'Bathroom fitting'],
      rating: 4.7,
      jobCount: 120,
      verified: true,
      verificationLevel: VerificationLevel.governmentId,
      gender: Gender.male,
      latitude: 16.7049,
      longitude: 74.2433,
      status: WorkerStatus.available,
      riskScore: 0.1,
    ),
    Worker(
      id: '2',
      name: 'Priya Sharma',
      primaryCategory: ServiceCategory.electrician,
      skills: const ['Wiring', 'Appliance install'],
      rating: 4.8,
      jobCount: 200,
      verified: true,
      verificationLevel: VerificationLevel.fullyBackgroundChecked,
      gender: Gender.female,
      latitude: 16.7089,
      longitude: 74.2473,
      status: WorkerStatus.busy,
      riskScore: 0.05,
    ),
    Worker(
      id: '3',
      name: 'Rajesh Kumar',
      primaryCategory: ServiceCategory.mechanic,
      skills: const ['Auto repair', 'Bike service'],
      rating: 4.6,
      jobCount: 150,
      verified: true,
      verificationLevel: VerificationLevel.governmentId,
      gender: Gender.male,
      latitude: 16.7029,
      longitude: 74.2403,
      status: WorkerStatus.available,
      riskScore: 0.15,
    ),
    Worker(
      id: '4',
      name: 'Anita Desai',
      primaryCategory: ServiceCategory.maid,
      skills: const ['House cleaning', 'Cooking'],
      rating: 4.9,
      jobCount: 300,
      verified: true,
      verificationLevel: VerificationLevel.fullyBackgroundChecked,
      gender: Gender.female,
      latitude: 16.7069,
      longitude: 74.2453,
      status: WorkerStatus.off,
      riskScore: 0.02,
    ),
    Worker(
      id: '5',
      name: 'Vikram Singh',
      primaryCategory: ServiceCategory.plumber,
      skills: const ['Pipe installation', 'Tank repair'],
      rating: 4.5,
      jobCount: 95,
      verified: false,
      verificationLevel: VerificationLevel.basic,
      gender: Gender.male,
      latitude: 16.7059,
      longitude: 74.2413,
      status: WorkerStatus.busy,
      riskScore: 0.4,
    ),
    Worker(
      id: '6',
      name: 'Meera Nair',
      primaryCategory: ServiceCategory.electrician,
      skills: const ['Solar panel', 'Smart home'],
      rating: 4.7,
      jobCount: 110,
      verified: true,
      verificationLevel: VerificationLevel.fullyBackgroundChecked,
      gender: Gender.female,
      latitude: 16.7079,
      longitude: 74.2443,
      status: WorkerStatus.available,
      riskScore: 0.08,
    ),
    Worker(
      id: '7',
      name: 'Amit Joshi',
      primaryCategory: ServiceCategory.mechanic,
      skills: const ['Car service', 'AC repair'],
      rating: 4.4,
      jobCount: 80,
      verified: false,
      verificationLevel: VerificationLevel.basic,
      gender: Gender.male,
      latitude: 16.7039,
      longitude: 74.2423,
      status: WorkerStatus.off,
      riskScore: 0.25,
    ),
    Worker(
      id: '8',
      name: 'Sunita Rao',
      primaryCategory: ServiceCategory.maid,
      skills: const ['Deep cleaning', 'Laundry'],
      rating: 4.8,
      jobCount: 250,
      verified: true,
      verificationLevel: VerificationLevel.fullyBackgroundChecked,
      gender: Gender.female,
      latitude: 16.7099,
      longitude: 74.2463,
      status: WorkerStatus.available,
      riskScore: 0.03,
    ),
    Worker(
      id: '9',
      name: 'Rohan Deshmukh',
      primaryCategory: ServiceCategory.roadsideAssistance,
      skills: const ['Towing', 'Battery Jumpstart', 'Tire Change'],
      rating: 4.9,
      jobCount: 412,
      verified: true,
      verificationLevel: VerificationLevel.fullyBackgroundChecked,
      gender: Gender.male,
      latitude: 16.7019,
      longitude: 74.2483,
      status: WorkerStatus.available,
      riskScore: 0.05,
    ),
  ];
});

final filteredWorkersProvider = Provider<List<Worker>>((ref) {
  final all = ref.watch(workersProvider);
  final filters = ref.watch(searchFiltersProvider);
  final userProfile = ref.watch(userProfileProvider);

  var filtered = all.where((w) {
    // 1. Women Safety Mode: Strict Verification Check
    if (filters.womenSafetyMode) {
      // Only show government ID verified + background checked
      if (w.verificationLevel != VerificationLevel.fullyBackgroundChecked) {
        return false;
      }
    }

    // 2. Risk Monitoring: AI-based thresholding
    if (filters.riskMonitoring) {
      if (w.riskScore > 0.3) return false;
    }

    // 3. Gender Preference
    if (filters.genderPreference == 'female' && w.gender != Gender.female) {
      return false;
    }
    if (filters.genderPreference == 'male' && w.gender != Gender.male) {
      return false;
    }

    // Standard business logic filters
    if (filters.categories.isNotEmpty &&
        !filters.categories.contains(w.primaryCategory)) {
      return false;
    }
    if (filters.categories.isEmpty &&
        filters.serviceCategory != null &&
        w.primaryCategory != filters.serviceCategory) {
      return false;
    }
    if (w.rating < filters.minRating) return false;
    if (filters.verifiedOnly && !w.verified) return false;

    return true;
  }).toList();

  // Advanced Sorting Logic for Safety & Trust
  filtered.sort((a, b) {
    if (filters.womenSafetyMode) {
      // Prioritize same-gender matches for female users in Safety Mode
      if (userProfile?.gender == Gender.female) {
        if (a.gender == Gender.female && b.gender != Gender.female) return -1;
        if (a.gender != Gender.female && b.gender == Gender.female) return 1;
      }

      // Then sort by risk score (lower is better)
      if (a.riskScore != b.riskScore) {
        return a.riskScore.compareTo(b.riskScore);
      }
    }

    // Default: Sort by rating (highest first)
    return b.rating.compareTo(a.rating);
  });

  return filtered;
});
