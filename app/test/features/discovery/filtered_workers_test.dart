import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/discovery/data/worker_providers.dart';
import 'package:app/core/ai/ai_providers.dart';
import 'package:app/core/ai/gemini_service.dart';
import 'package:app/core/enums/service_category.dart';

void main() {
  test('filteredWorkersProvider returns all workers by default', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final workers = container.read(filteredWorkersProvider);

    // Print count for debugging
    print('Total workers: ${workers.length}');

    // Expecting 30 workers based on new data
    expect(workers.isNotEmpty, true);
    expect(workers.length, 30);
  });

  test('filteredWorkersProvider respects categories filter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Set filter to 'Maid'
    container
        .read(searchFiltersProvider.notifier)
        .update(const SearchFilters(serviceCategory: ServiceCategory.maid));

    final workers = container.read(filteredWorkersProvider);
    print('Maid workers: ${workers.length}');

    // Verify all returned workers are maids
    for (final w in workers) {
      expect(w.primaryCategory, ServiceCategory.maid);
    }
    expect(workers.isNotEmpty, true);
  });
}
