import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/ai_providers.dart';
import '../../../core/emergency/emergency_providers.dart';
import '../../../core/enums/service_category.dart';
import 'worker_models.dart';

final workersProvider = Provider<List<Worker>>((ref) {
  return [
    Worker(
      id: 'W_GAS_1',
      name: 'Gopal Gas Tech',
      primaryCategory: ServiceCategory.gasService,
      skills: const ['Gas leak detection', 'LPG repair', 'Pipe safety'],
      rating: 4.9,
      jobCount: 312,
      verified: true,
      latitude: 16.7050,
      longitude: 74.2430,
      status: WorkerStatus.available,
      responseTimeMinutes: 3,
    ),
    Worker(
      id: 'W_GAS_2',
      name: 'Suresh LPG Expert',
      primaryCategory: ServiceCategory.gasService,
      skills: const ['LPG stove repair', 'Gas connection', 'Safety audit'],
      rating: 4.7,
      jobCount: 185,
      verified: true,
      latitude: 16.7150,
      longitude: 74.2530,
      status: WorkerStatus.available,
      responseTimeMinutes: 7,
    ),
    Worker(
      id: 'W1',
      name: 'Anita Desai',
      primaryCategory: ServiceCategory.maid,
      skills: const ['Maid', 'House cleaning'],
      rating: 4.9,
      jobCount: 154,
      verified: true,
      latitude: 16.7055,
      longitude: 74.2435,
      status: WorkerStatus.available,
      responseTimeMinutes: 5,
    ),
    Worker(
      id: 'W2',
      name: 'Ramesh Patil',
      primaryCategory: ServiceCategory.maid,
      skills: const ['Maid'],
      rating: 4.5,
      jobCount: 89,
      verified: false,
      latitude: 16.7120,
      longitude: 74.2450,
      status: WorkerStatus.available,
      responseTimeMinutes: 15,
    ),
    Worker(
      id: 'W3',
      name: 'Sunita Jadhav',
      primaryCategory: ServiceCategory.plumber,
      skills: const ['Plumber', 'Emergency repair'],
      rating: 4.7,
      jobCount: 210,
      verified: true,
      verificationLevel: VerificationLevel.governmentId,
      gender: Gender.male,
      latitude: 16.7049,
      longitude: 74.2433,
      status: WorkerStatus.available,
      riskScore: 0.1,
      latitude: 16.6942,
      longitude: 74.2410,
      status: WorkerStatus.available,
      responseTimeMinutes: 10,
    ),
    Worker(
      id: 'W4',
      name: 'Mahesh Shinde',
      primaryCategory: ServiceCategory.electrician,
      skills: const ['Electrician'],
      rating: 4.3,
      jobCount: 65,
      verified: true,
      verificationLevel: VerificationLevel.fullyBackgroundChecked,
      gender: Gender.female,
      latitude: 16.7089,
      longitude: 74.2473,
      status: WorkerStatus.busy,
      riskScore: 0.05,
      latitude: 16.7360,
      longitude: 74.2480,
      status: WorkerStatus.available,
      responseTimeMinutes: 20,
    ),
    Worker(
      id: 'W5',
      name: 'Kiran Pawar',
      primaryCategory: ServiceCategory.mechanic,
      skills: const ['Mechanic', 'Roadside assistance'],
      rating: 4.8,
      jobCount: 132,
      verified: true,
      verificationLevel: VerificationLevel.governmentId,
      gender: Gender.male,
      latitude: 16.7029,
      longitude: 74.2403,
      status: WorkerStatus.available,
      riskScore: 0.15,
      latitude: 16.7050,
      longitude: 74.2612,
      status: WorkerStatus.available,
      responseTimeMinutes: 8,
    ),
    Worker(
      id: 'W6',
      name: 'Deepak More',
      primaryCategory: ServiceCategory.mechanic,
      skills: const ['Mechanic'],
      rating: 3.9,
      jobCount: 42,
      verified: false,
      latitude: 16.6672,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 25,
    ),
    Worker(
      id: 'W7',
      name: 'Priya Kulkarni',
      primaryCategory: ServiceCategory.maid,
      skills: const ['Maid'],
      rating: 4.2,
      jobCount: 98,
      verified: true,
      verificationLevel: VerificationLevel.fullyBackgroundChecked,
      gender: Gender.female,
      latitude: 16.7069,
      longitude: 74.2453,
      status: WorkerStatus.off,
      riskScore: 0.02,
      latitude: 16.7185,
      longitude: 74.2490,
      status: WorkerStatus.off,
      responseTimeMinutes: 12,
    ),
    Worker(
      id: 'W8',
      name: 'Suresh Naik',
      primaryCategory: ServiceCategory.plumber,
      skills: const ['Plumber'],
      rating: 4.6,
      jobCount: 112,
      verified: false,
      verificationLevel: VerificationLevel.basic,
      gender: Gender.male,
      latitude: 16.7059,
      longitude: 74.2413,
      status: WorkerStatus.busy,
      riskScore: 0.4,
      latitude: 16.7080,
      longitude: 74.2405,
      status: WorkerStatus.available,
      responseTimeMinutes: 7,
    ),
    Worker(
      id: 'W9',
      name: 'Ajay Patil',
      primaryCategory: ServiceCategory.electrician,
      skills: const ['Electrician', 'Emergency repair'],
      rating: 4.9,
      jobCount: 180,
      verified: true,
      latitude: 16.6970,
      longitude: 74.2380,
      status: WorkerStatus.available,
      responseTimeMinutes: 6,
    ),
    Worker(
      id: 'W10',
      name: 'Neha Chavan',
      primaryCategory: ServiceCategory.maid,
      skills: const ['Maid', 'Deep cleaning'],
      rating: 4.4,
      jobCount: 76,
      verified: true,
      latitude: 16.7050,
      longitude: 74.2680,
      status: WorkerStatus.available,
      responseTimeMinutes: 18,
    ),
    Worker(
      id: 'W11',
      name: 'Vijay More',
      primaryCategory: ServiceCategory.plumber,
      skills: const ['Plumber'],
      rating: 4.1,
      jobCount: 55,
      verified: true,
      latitude: 16.7025,
      longitude: 74.2445,
      status: WorkerStatus.available,
      responseTimeMinutes: 9,
    ),
    Worker(
      id: 'W12',
      name: 'Pooja Sawant',
      primaryCategory: ServiceCategory.electrician,
      skills: const ['Electrician'],
      rating: 4.8,
      jobCount: 145,
      verified: true,
      latitude: 16.7200,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 11,
    ),
    Worker(
      id: 'W13',
      name: 'Ganesh Mane',
      primaryCategory: ServiceCategory.mechanic,
      skills: const ['Mechanic'],
      rating: 4.6,
      jobCount: 123,
      verified: true,
      latitude: 16.7095,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 6,
    ),
    Worker(
      id: 'W14',
      name: 'Rahul Kadam',
      primaryCategory: ServiceCategory.roadsideAssistance,
      skills: const ['Roadside assistance'],
      rating: 4.0,
      jobCount: 90,
      verified: false,
      latitude: 16.7320,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 22,
    ),
    Worker(
      id: 'W15',
      name: 'Sneha Patil',
      primaryCategory: ServiceCategory.maid,
      skills: const ['Maid'],
      rating: 4.7,
      jobCount: 205,
      verified: true,
      verificationLevel: VerificationLevel.fullyBackgroundChecked,
      gender: Gender.female,
      latitude: 16.7079,
      longitude: 74.2443,
      status: WorkerStatus.available,
      riskScore: 0.08,
      latitude: 16.7068,
      longitude: 74.2430,
      status: WorkerStatus.available,
      responseTimeMinutes: 4,
    ),
    Worker(
      id: 'W16',
      name: 'Amol Jagtap',
      primaryCategory: ServiceCategory.electrician,
      skills: const ['Electrician'],
      rating: 3.8,
      jobCount: 40,
      verified: false,
      latitude: 16.7450,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 30,
    ),
    Worker(
      id: 'W17',
      name: 'Shweta Bhosale',
      primaryCategory: ServiceCategory.plumber,
      skills: const ['Plumber'],
      rating: 4.5,
      jobCount: 100,
      verified: true,
      latitude: 16.7248,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 14,
    ),
    Worker(
      id: 'W18',
      name: 'Rohit Pawar',
      primaryCategory: ServiceCategory.mechanic,
      skills: const ['Mechanic'],
      rating: 4.4,
      jobCount: 88,
      verified: true,
      latitude: 16.7140,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 9,
    ),
    Worker(
      id: 'W19',
      name: 'Vaishali Kulkarni',
      primaryCategory: ServiceCategory.maid,
      skills: const ['Maid', 'Deep cleaning'],
      rating: 4.6,
      jobCount: 167,
      verified: true,
      latitude: 16.7338,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 16,
    ),
    Worker(
      id: 'W20',
      name: 'Nitin Patil',
      primaryCategory: ServiceCategory.electrician,
      skills: const ['Electrician'],
      rating: 4.9,
      jobCount: 230,
      verified: true,
      latitude: 16.7113,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 5,
    ),
    Worker(
      id: 'W21',
      name: 'Sanjay Shinde',
      primaryCategory: ServiceCategory.plumber,
      skills: const ['Plumber'],
      rating: 3.7,
      jobCount: 35,
      verified: false,
      verificationLevel: VerificationLevel.basic,
      gender: Gender.male,
      latitude: 16.7039,
      longitude: 74.2423,
      status: WorkerStatus.off,
      riskScore: 0.25,
      latitude: 16.7499,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 35,
    ),
    Worker(
      id: 'W22',
      name: 'Kavita More',
      primaryCategory: ServiceCategory.maid,
      skills: const ['Maid'],
      rating: 4.3,
      jobCount: 95,
      verified: true,
      latitude: 16.7149,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 13,
    ),
    Worker(
      id: 'W23',
      name: 'Prakash Chavan',
      primaryCategory: ServiceCategory.mechanic,
      skills: const ['Mechanic', 'Roadside assistance'],
      rating: 4.7,
      jobCount: 140,
      verified: true,
      latitude: 16.7275,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 7,
    ),
    Worker(
      id: 'W24',
      name: 'Meena Jadhav',
      primaryCategory: ServiceCategory.maid,
      skills: const ['Maid'],
      rating: 4.1,
      jobCount: 60,
      verified: false,
      latitude: 16.7482, // 4.8km
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 20,
    ),
    Worker(
      id: 'W25',
      name: 'Harshal Patil',
      primaryCategory: ServiceCategory.electrician,
      skills: const ['Electrician'],
      rating: 4.6,
      jobCount: 115,
      verified: true,
      latitude: 16.7131,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 8,
    ),
    Worker(
      id: 'W26',
      name: 'Tanvi Kulkarni',
      primaryCategory: ServiceCategory.plumber,
      skills: const ['Plumber'],
      rating: 4.2,
      jobCount: 78,
      verified: true,
      latitude: 16.7221,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 17,
    ),
    Worker(
      id: 'W27',
      name: 'Yogesh Pawar',
      primaryCategory: ServiceCategory.mechanic,
      skills: const ['Mechanic'],
      rating: 4.8,
      jobCount: 155,
      verified: true,
      latitude: 16.7077,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 6,
    ),
    Worker(
      id: 'W28',
      name: 'Komal Shinde',
      primaryCategory: ServiceCategory.maid,
      skills: const ['Maid'],
      rating: 4.5,
      jobCount: 105,
      verified: true,
      verificationLevel: VerificationLevel.fullyBackgroundChecked,
      gender: Gender.female,
      latitude: 16.7099,
      longitude: 74.2463,
      status: WorkerStatus.available,
      riskScore: 0.03,
      latitude: 16.7284,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 14,
    ),
    Worker(
      id: 'W29',
      name: 'Dinesh More',
      primaryCategory: ServiceCategory.roadsideAssistance,
      skills: const ['Roadside assistance'],
      rating: 4.3,
      jobCount: 82,
      verified: false,
      latitude: 16.7176,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 10,
    ),
    Worker(
      id: 'W30',
      name: 'Pallavi Patil',
      primaryCategory: ServiceCategory.electrician,
      skills: const ['Electrician'],
      rating: 4.4,
      jobCount: 92,
      verified: true,
      verificationLevel: VerificationLevel.fullyBackgroundChecked,
      gender: Gender.male,
      latitude: 16.7019,
      longitude: 74.2483,
      status: WorkerStatus.available,
      riskScore: 0.05,
      latitude: 16.7383,
      longitude: 74.2433,
      status: WorkerStatus.available,
      responseTimeMinutes: 19,
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
    // Fallback to single serviceCategory when no multi-select
    // Treat 'other' as wildcard to show all workers
    if (filters.categories.isEmpty &&
        filters.serviceCategory != null &&
        filters.serviceCategory != ServiceCategory.other &&
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
