import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/worker_providers.dart';
import '../data/worker_models.dart';
import '../../../core/ai/ai_providers.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/theme/app_theme.dart';

class WorkerDiscoveryScreen extends ConsumerStatefulWidget {
  const WorkerDiscoveryScreen({super.key});

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
      final hue = _getCategoryHue(worker.primaryCategory);
      return Marker(
        markerId: MarkerId(worker.id),
        position: LatLng(worker.latitude, worker.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(
          title: worker.name,
          snippet:
              '${worker.primaryCategory.name} • ⭐ ${worker.rating.toStringAsFixed(1)}',
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

    final workers = ref.watch(filteredWorkersProvider);
    final markers = _buildMarkers(workers);

    return Scaffold(
      body: Stack(
        children: [
          // Full screen map
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

          // Floating UI elements
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: _FloatingSearchBar(
                    controller: _searchController,
                    onSubmitted: (query) {
                      ref.read(searchFiltersProvider.notifier).fromQuery(query);
                    },
                    onFilterTap: () {
                      setState(() {
                        _filtersExpanded = !_filtersExpanded;
                      });
                    },
                  ),
                ),

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

          // Bottom worker list preview (over map, still allows map interaction above it)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 220,
                child: _BottomWorkerList(
                  onViewAll: () {
                    setState(() {
                      _showListView = true;
                    });
                  },
                ),
              ),
            ),
          ),

          // My location button
          Positioned(
            right: 16,
            bottom: 200,
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
                  ref
                      .read(searchFiltersProvider.notifier)
                      .update(
                        currentFilters.copyWith(
                          categories: _selectedCategories.toList(),
                          radiusKm: _radiusKm,
                          verifiedOnly: _verifiedOnly,
                          minRating: _highRating ? 4.0 : 0.0,
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

class _WorkerCardVertical extends StatelessWidget {
  final Worker worker;

  const _WorkerCardVertical({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
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
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  worker.primaryCategory.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Rating
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            worker.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFBBF24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Jobs completed
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

class _BottomWorkerList extends ConsumerWidget {
  final VoidCallback onViewAll;

  const _BottomWorkerList({required this.onViewAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workers = ref.watch(filteredWorkersProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${workers.length} workers nearby',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onViewAll,
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: workers.length > 5 ? 5 : workers.length,
              itemBuilder: (context, index) {
                return _WorkerCardHorizontal(worker: workers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkerCardHorizontal extends StatelessWidget {
  final Worker worker;

  const _WorkerCardHorizontal({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
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
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  worker.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (worker.verified)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 10,
                    color: Color(0xFF10B981),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  worker.primaryCategory.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.star_rounded,
                size: 12,
                color: Color(0xFFFBBF24),
              ),
              const SizedBox(width: 3),
              Text(
                worker.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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
