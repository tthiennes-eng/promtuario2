import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/features/dashboard/data/repositories/statistical_studies_repository.dart';

enum StatisticalPeriodFilter {
  all('Todo o período'),
  days30('Últimos 30 dias'),
  days90('Últimos 90 dias'),
  months6('Últimos 6 meses'),
  year1('Último ano');

  final String label;
  const StatisticalPeriodFilter(this.label);

  DateTime? get startDate {
    final now = DateTime.now();
    switch (this) {
      case StatisticalPeriodFilter.all:
        return null;
      case StatisticalPeriodFilter.days30:
        return now.subtract(const Duration(days: 30));
      case StatisticalPeriodFilter.days90:
        return now.subtract(const Duration(days: 90));
      case StatisticalPeriodFilter.months6:
        return DateTime(now.year, now.month - 6, now.day);
      case StatisticalPeriodFilter.year1:
        return DateTime(now.year - 1, now.month, now.day);
    }
  }
}

class StatisticalFilter {
  final StatisticalPeriodFilter period;
  final String? clinicId;

  const StatisticalFilter({
    this.period = StatisticalPeriodFilter.all,
    this.clinicId,
  });

  StatisticalFilter copyWith({
    StatisticalPeriodFilter? period,
    String? clinicId,
    bool clearClinic = false,
  }) {
    return StatisticalFilter(
      period: period ?? this.period,
      clinicId: clearClinic ? null : (clinicId ?? this.clinicId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticalFilter &&
          period == other.period &&
          clinicId == other.clinicId;

  @override
  int get hashCode => Object.hash(period, clinicId);
}

final statisticalStudiesRepositoryProvider = Provider<StatisticalStudiesRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  final db = ref.watch(databaseProvider);
  return StatisticalStudiesRepository(api, db);
});

final statisticalFilterProvider = StateProvider<StatisticalFilter>((ref) {
  return const StatisticalFilter();
});

final statisticalStudiesProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(statisticalStudiesRepositoryProvider);
  final filter = ref.watch(statisticalFilterProvider);
  return repo.getStatisticalStudies(
    start: filter.period.startDate,
    end: filter.period == StatisticalPeriodFilter.all ? null : DateTime.now(),
    clinicId: filter.clinicId,
  );
});
