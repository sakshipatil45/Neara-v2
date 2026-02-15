import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/worker_providers.dart';
import '../data/worker_models.dart';

import '../../../core/ai/ai_providers.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/controllers/request_controller.dart';
import '../../../core/enums/service_category.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/emergency/emergency_providers.dart';
import '../../emergency/sos_confirmation_screen.dart';

class WorkerDiscoveryScreen extends ConsumerStatefulWidget {
  final List<WorkerRanking>? recommendations;

  const WorkerDiscoveryScreen({super.key, this.recommendations});

  @override
  ConsumerState<WorkerDiscoveryScreen> createState() =>
      _WorkerDiscoveryScreenState();
}

class _WorkerDiscoveryScreenState extends ConsumerState<WorkerDiscoveryScreen> {
  GoogleMapController? _mapController;
  bool _filtersExpanded = false;
  bool _showListView = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(List<Worker> workers) {
    return workers.map((worker) {
      // Check if this worker has a highlighed ranking
      final ranking = widget.recommendations?.firstWhere(
        (r) => r.workerId == worker.id,
        orElse: () =>
            WorkerRanking(workerId: '', score: 0, reason: '', worker: worker),
      );
      final isHighlighted = ranking?.highlightMarker ?? false;

      final hue = _getCategoryHue(worker.primaryCategory);
      return Marker(
        markerId: MarkerId(worker.id),
        position: LatLng(worker.latitude, worker.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        // Simple highlight by increasing z-index or changing icon could be done here if custom icons were used.
        // For now, we rely on the list to show the recommendation details.
        zIndex: isHighlighted ? 10 : 1.0,
        infoWindow: InfoWindow(
          title: worker.name,
          snippet:
              '${worker.primaryCategory.name} • ⭐ ${worker.rating.toStringAsFixed(1)}${isHighlighted ? " (Recommended)" : ""}',
        ),
        onTap: () {
          _showWorkerDetails(worker);
        },
      );
    }).toSet();
  }

  double _getCategoryHue(ServiceCategory category) {
    return switch (category) {
      ServiceCategory.plumber => BitmapDescriptor.hueBlue,
      ServiceCategory.electrician => BitmapDescriptor.hueYellow,
      ServiceCategory.mechanic => BitmapDescriptor.hueRed,
      ServiceCategory.maid => BitmapDescriptor.hueMagenta,
      ServiceCategory.roadsideAssistance => BitmapDescriptor.hueRose,
      ServiceCategory.gasService => BitmapDescriptor.hueCyan,
      ServiceCategory.other => BitmapDescriptor.hueOrange,
    };
  }

  void _showWorkerDetails(Worker worker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _WorkerDetailSheet(worker: worker),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showListView) {
      return _WorkerListView(
        onBack: () {
          setState(() {
            _showListView = false;
          });
        },
      );
    }

    // If recommendations exist, use them. Otherwise use provider.
    final List<Worker> workers;
    if (widget.recommendations != null && widget.recommendations!.isNotEmpty) {
      workers = widget.recommendations!
          .where((r) => r.worker != null)
          .map((r) => r.worker!)
          .toList();
    } else {
      workers = ref.watch(filteredWorkersProvider) ?? [];
    }

    final markers = _buildMarkers(workers);

    return Scaffold(
      body: Stack(
        children: [
          // ... GoogleMap ...
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(16.7049, 74.2433),
              zoom: 13,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: markers,
          ),

          // ... Floating UI elements ...
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: _FloatingSearchBar(
                    controller: _searchController,
                    onSubmitted: (query) async {
                      // Use unified request controller for consistent flow
                      final controller = createRequestController(ref, context);
                      await controller.handleUserRequest(query);
                    },
                    onFilterTap: () {
                      setState(() {
                        _filtersExpanded = !_filtersExpanded;
                      });
                    },
                  ),
                ),

                // Safety Mode Indicator Banner
                Consumer(
                  builder: (context, ref, child) {
                    final safetyMode =
                        ref.watch(searchFiltersProvider).womenSafetyMode;
                    if (!safetyMode) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.shield_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Safety Mode Active',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ),
                            const Text(
                              'Verified Only',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                // Collapsible filter panel
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _filtersExpanded ? 280 : 0,
                  child: _filtersExpanded
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _FloatingFilterPanel(
                            onClose: () {
                              setState(() {
                                _filtersExpanded = false;
                              });
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Bottom worker list preview
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 330, // Increased height for enhanced cards with badges
                child: _BottomWorkerList(
                  title: widget.recommendations != null
                      ? 'Recommended for You'
                      : 'Workers Nearby',
                  isRecommendation: widget.recommendations != null,
                  workers: workers,
                  rankings: widget.recommendations, // Pass rankings
                  onViewAll: () {
                    setState(() {
                      _showListView = true;
                    });
                  },
                ),
              ),
            ),
          ),

          // SOS Button - Easy Access
          Positioned(
            right: 16,
            bottom: 260,
            child: Consumer(
              builder: (context, ref, child) {
                final canAccessSOS = ref.watch(canAccessSOSProvider);
                final hasMinimumContacts =
                    ref.watch(emergencyContactsProvider).length >= 3;
                final safetyMode =
                    ref.watch(searchFiltersProvider).womenSafetyMode;

                if (!canAccessSOS || !hasMinimumContacts) {
                  return const SizedBox.shrink();
                }

                if (safetyMode) {
                  return const _PulsingSOSButton();
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SOSConfirmationScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFDC2626),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withOpacity(0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
          ),

          // Safety Status Overlays
          Positioned(
            top: 100,
            left: 16,
            child: Consumer(
              builder: (context, ref, child) {
                final filters = ref.watch(searchFiltersProvider);
                if (!filters.womenSafetyMode) return const SizedBox.shrink();

                // Check for any workers with riskScore > 0.3
                final allWorkers = ref.watch(workersProvider);
                final hasHighRisk = allWorkers.any((w) => w.riskScore > 0.3);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (filters.riskMonitoring)
                      hasHighRisk
                          ? _SafetyStatusBadge(
                              icon: Icons.warning_amber_rounded,
                              label: 'ADVISORY: HIGH RISK AREA',
                              reason:
                                  'Suspicious behavior patterns detected nearby',
                              color: const Color(0xFFDC2626),
                            )
                          : _SafetyStatusBadge(
                              icon: Icons.verified_user_rounded,
                              label: 'SECURE: SAFE AREA',
                              reason:
                                  'No suspicious activity detected in this zone',
                              color: const Color(0xFF10B981),
                            ),
                    const SizedBox(height: 8),
                    if (filters.liveTracking)
                      _SafetyStatusBadge(
                        icon: Icons.location_searching_rounded,
                        label: filters.shareWithPrioritized &&
                                ref
                                        .watch(
                                            emergencyContactsProvider.notifier)
                                        .primaryContact !=
                                    null
                            ? 'LIVE: SHARING WITH ${ref.watch(emergencyContactsProvider.notifier).primaryContact?.name.toUpperCase()}'
                            : 'LIVE: TRACKING SHARED',
                        reason: filters.shareWithPrioritized
                            ? 'Selected contact is receiving live updates'
                            : 'Real-time location is being shared with contacts',
                        color: const Color(0xFF6366F1),
                      ),
                  ],
                );
              },
            ),
          ),

          // My location button
          // ... My location button ...
          Positioned(
            right: 16,
            bottom: 220,
            child: _GlassButton(
              icon: Icons.my_location,
              onTap: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(const LatLng(16.7049, 74.2433)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSubmitted;
  final VoidCallback onFilterTap;

  const _FloatingSearchBar({
    required this.controller,
    required this.onSubmitted,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Search for services...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          GestureDetector(
            onTap: onFilterTap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.tune_rounded,
                color: const Color(0xFF6366F1),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingFilterPanel extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const _FloatingFilterPanel({required this.onClose});

  @override
  ConsumerState<_FloatingFilterPanel> createState() =>
      _FloatingFilterPanelState();
}

class _FloatingFilterPanelState extends ConsumerState<_FloatingFilterPanel> {
  double _radiusKm = 5;
  bool _verifiedOnly = true;
  bool _highRating = true;
  bool _womenSafetyMode = false;
  String _genderPreference = 'any';
  bool _liveTracking = false;
  bool _riskMonitoring = false;
  final Set<ServiceCategory> _selectedCategories = {};

  @override
  void initState() {
    super.initState();
    final current = ref.read(searchFiltersProvider);
    if (current.categories.isNotEmpty) {
      _selectedCategories.addAll(current.categories);
    } else if (current.serviceCategory != null) {
      _selectedCategories.add(current.serviceCategory!);
    }
    // Clamp radius to the Slider's allowed range to avoid assertion errors
    _radiusKm = current.radiusKm.clamp(1.0, 20.0).toDouble();
    _verifiedOnly = current.verifiedOnly;
    _highRating = current.minRating >= 4.0;
    _womenSafetyMode = current.womenSafetyMode;
    _genderPreference = current.genderPreference;
    _liveTracking = current.liveTracking;
    _riskMonitoring = current.riskMonitoring;
  }

  Widget _buildGenderOption(String value, String label) {
    final bool isSelected = _genderPreference == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _genderPreference = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6366F1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Service categories',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in ServiceCategory.values)
                  _CategoryChip(
                    label: category == ServiceCategory.roadsideAssistance
                        ? 'Roadside assistance'
                        : category.name[0].toUpperCase() +
                            category.name.substring(1),
                    selected: _selectedCategories.contains(category),
                    onTap: () {
                      setState(() {
                        if (_selectedCategories.contains(category)) {
                          _selectedCategories.remove(category);
                        } else {
                          _selectedCategories.add(category);
                        }
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Distance: ${_radiusKm.toInt()} km',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF6366F1),
                inactiveTrackColor: const Color(0xFFE2E8F0),
                thumbColor: const Color(0xFF6366F1),
                overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
              ),
              child: Slider(
                value: _radiusKm,
                min: 1,
                max: 20,
                divisions: 19,
                onChanged: (value) {
                  setState(() {
                    _radiusKm = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            _FilterToggleRow(
              label: '4★+ rating',
              value: _highRating,
              onChanged: (value) {
                setState(() {
                  _highRating = value;
                });
              },
            ),
            const SizedBox(height: 12),
            _FilterToggleRow(
              label: 'Verified only',
              value: _verifiedOnly,
              onChanged: (value) {
                setState(() {
                  _verifiedOnly = value;
                });
              },
            ),
            const SizedBox(height: 12),
            // Gender Preference
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gender Preference',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildGenderOption('any', 'ANY'),
                    const SizedBox(width: 8),
                    _buildGenderOption('female', 'FEMALE'),
                    const SizedBox(width: 8),
                    _buildGenderOption('male', 'MALE'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Women Safety Mode Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _womenSafetyMode
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _womenSafetyMode
                      ? const Color(0xFFD97706)
                      : const Color(0xFFE2E8F0),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _womenSafetyMode
                              ? const Color(0xFFD97706)
                              : const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Women Safety Mode',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _womenSafetyMode
                                ? const Color(0xFF92400E)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Switch(
                        value: _womenSafetyMode,
                        onChanged: (value) {
                          setState(() {
                            _womenSafetyMode = value;
                            if (value) {
                              _verifiedOnly = true;
                              _highRating = true;
                              _riskMonitoring = true;
                            }
                          });
                        },
                        activeColor: const Color(0xFFD97706),
                        activeTrackColor:
                            const Color(0xFFD97706).withOpacity(0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Exclusive verified network & enhanced tracking',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_womenSafetyMode) ...[
                    const SizedBox(height: 12),
                    _FilterToggleRow(
                      label: 'Live Tracking',
                      value: _liveTracking,
                      onChanged: (value) =>
                          setState(() => _liveTracking = value),
                    ),
                    const SizedBox(height: 8),
                    _FilterToggleRow(
                      label: 'Risk Monitor',
                      value: _riskMonitoring,
                      onChanged: (value) =>
                          setState(() => _riskMonitoring = value),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppGradients.accentGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Apply filters
                  final currentFilters = ref.read(searchFiltersProvider);
                  ref.read(searchFiltersProvider.notifier).update(
                        currentFilters.copyWith(
                          categories: _selectedCategories.toList(),
                          radiusKm: _radiusKm,
                          verifiedOnly: _verifiedOnly,
                          minRating: _highRating ? 4.0 : 0.0,
                          womenSafetyMode: _womenSafetyMode,
                          genderPreference: _genderPreference,
                          liveTracking: _liveTracking,
                          riskMonitoring: _riskMonitoring,
                        ),
                      );
                  widget.onClose();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 15,
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
}

class _WorkerListView extends ConsumerWidget {
  final VoidCallback onBack;

  const _WorkerListView({required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workers = ref.watch(filteredWorkersProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF1E293B),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${workers.length} Workers Nearby',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              // Worker list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    return _WorkerCardVertical(worker: workers[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingSOSButton extends StatefulWidget {
  const _PulsingSOSButton();

  @override
  State<_PulsingSOSButton> createState() => _PulsingSOSButtonState();
}

class _PulsingSOSButtonState extends State<_PulsingSOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SOSConfirmationScreen(),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 56 + (40 * _animation.value),
                height: 56 + (40 * _animation.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      const Color(0xFFDC2626).withOpacity(1 - _animation.value),
                ),
              );
            },
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFDC2626),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDC2626).withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.emergency_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkerCardVertical extends ConsumerWidget {
  final Worker worker;

  const _WorkerCardVertical({required this.worker});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safetyMode = ref.watch(searchFiltersProvider).womenSafetyMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: safetyMode && worker.verified
            ? Border.all(
                color: const Color(0xFFD97706).withOpacity(0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: safetyMode && worker.verified
                ? const Color(0xFFD97706).withOpacity(0.1)
                : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.accentGradient,
                ),
                child: Center(
                  child: Text(
                    worker.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              if (worker.status == WorkerStatus.available)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Worker details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        worker.name,
                        style: TextStyle(
                          fontSize: safetyMode ? 19 : 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    if (worker.verified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: safetyMode
                              ? Border.all(
                                  color: const Color(0xFF10B981), width: 1)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              safetyMode ? 'Verified Check' : 'Verified',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (worker.verified)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            worker.verificationLevel ==
                                    VerificationLevel.fullyBackgroundChecked
                                ? '✓ FULLY CHECKED'
                                : worker.verificationLevel ==
                                        VerificationLevel.governmentId
                                    ? '✓ GOVT ID VERIFIED'
                                    : '✓ VERIFIED',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (safetyMode)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SAFE MATCH',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (safetyMode && worker.verified)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '✓ BACKGROUND CHECKED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD97706),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                Text(
                  worker.primaryCategory.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Rating
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: safetyMode ? 10 : 8,
                        vertical: safetyMode ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: safetyMode ? 16 : 14,
                            color: const Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            worker.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: safetyMode ? 14 : 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (safetyMode && worker.rating >= 4.5)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'HIGH TRUST',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Jobs completed
                    if (!safetyMode)
                      Flexible(
                        child: Text(
                          '${worker.jobCount} jobs',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF6366F1),
          activeTrackColor: const Color(0xFF6366F1).withOpacity(0.5),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.black : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.my_location_rounded,
          color: const Color(0xFF6366F1),
          size: 24,
        ),
      ),
    );
  }
}

class _BottomWorkerList extends StatelessWidget {
  final String title;
  final bool isRecommendation;
  final List<Worker> workers;
  final List<WorkerRanking>? rankings;
  final VoidCallback onViewAll;

  const _BottomWorkerList({
    required this.title,
    required this.isRecommendation,
    required this.workers,
    this.rankings,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (workers.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_off_rounded,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
              SizedBox(height: 12),
              Text(
                'No workers found nearby',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Try adjusting filters or searching for a different service.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              // Find ranking for this worker if available
              final ranking = rankings?.firstWhere(
                (r) => r.workerId == worker.id,
                orElse: () => WorkerRanking(
                  workerId: worker.id,
                  score: 0,
                  reason: '',
                  worker: worker,
                ),
              );

              return _WorkerCardHorizontal(
                worker: worker,
                ranking: ranking,
                isRecommended: isRecommendation,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WorkerCardHorizontal extends StatelessWidget {
  final Worker worker;
  final WorkerRanking? ranking;
  final bool isRecommended;

  const _WorkerCardHorizontal({
    required this.worker,
    this.ranking,
    required this.isRecommended,
  });

  @override
  Widget build(BuildContext context) {
    final isHighlighted =
        ranking?.highlightMarker == true || (isRecommended && ranking != null);
    final badgeLabel = ranking?.badgeLabel;
    final isFastResponse = worker.responseTimeMinutes < 20;

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isHighlighted
            ? LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: isHighlighted
            ? Border.all(width: 2, color: const Color(0xFF6366F1))
            : null,
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? const Color(0xFF6366F1).withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: isHighlighted ? 20 : 12,
            offset: const Offset(0, 4),
            spreadRadius: isHighlighted ? 2 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: isHighlighted
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color:
                  isHighlighted ? Colors.white.withOpacity(0.9) : Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top badges row
                if (badgeLabel != null && badgeLabel.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          badgeLabel.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Worker info row
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.accentGradient,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          worker.name[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _getCategoryIcon(worker.primaryCategory),
                                size: 14,
                                color: const Color(0xFF6366F1),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  worker.primaryCategory.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6366F1),
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Badges row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Rating badge
                    _Badge(
                      icon: Icons.star_rounded,
                      label: worker.rating.toStringAsFixed(1),
                      color: const Color(0xFFFBBF24),
                      backgroundColor: const Color(
                        0xFFFBBF24,
                      ).withOpacity(0.15),
                    ),
                    // Verified badge
                    if (worker.verified)
                      _Badge(
                        icon: Icons.verified,
                        label: 'VERIFIED',
                        color: const Color(0xFF10B981),
                        backgroundColor: const Color(
                          0xFF10B981,
                        ).withOpacity(0.15),
                      ),
                    // Fast response badge
                    if (isFastResponse)
                      _Badge(
                        icon: Icons.bolt,
                        label: '${worker.responseTimeMinutes}m',
                        color: const Color(0xFFEF4444),
                        backgroundColor: const Color(
                          0xFFEF4444,
                        ).withOpacity(0.15),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Skills
                Text(
                  worker.skills.take(3).join(' • '),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) =>
                            _WorkerDetailSheet(worker: worker),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'View Profile',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ServiceCategory category) {
    return switch (category) {
      ServiceCategory.plumber => Icons.plumbing,
      ServiceCategory.electrician => Icons.electrical_services,
      ServiceCategory.mechanic => Icons.build,
      ServiceCategory.maid => Icons.cleaning_services,
      ServiceCategory.roadsideAssistance => Icons.car_repair,
      ServiceCategory.gasService => Icons.gas_meter,
      ServiceCategory.other => Icons.handyman,
    };
  }
}

// Helper widget for badges
class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkerDetailSheet extends StatelessWidget {
  final Worker worker;

  const _WorkerDetailSheet({required this.worker});

  String get _statusLabel {
    switch (worker.status) {
      case WorkerStatus.available:
        return 'Available';
      case WorkerStatus.busy:
        return 'Busy';
      case WorkerStatus.off:
        return 'Off service time';
    }
  }

  Color get _statusColor {
    switch (worker.status) {
      case WorkerStatus.available:
        return const Color(0xFF10B981);
      case WorkerStatus.busy:
        return const Color(0xFFF97316);
      case WorkerStatus.off:
        return const Color(0xFF9CA3AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 30,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.accentGradient,
                ),
                child: Center(
                  child: Text(
                    worker.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      worker.primaryCategory.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      worker.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${worker.jobCount} jobs completed',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (worker.skills.isNotEmpty)
            Text(
              worker.skills.join(' • '),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.accentGradient,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Service request sent to ${worker.name}'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Request service',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyStatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? reason;
  final Color color;

  const _SafetyStatusBadge({
    required this.icon,
    required this.label,
    this.reason,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                if (reason != null)
                  Text(
                    reason!,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: color.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
