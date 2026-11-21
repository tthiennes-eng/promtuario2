// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Observa os indicadores do dashboard diretamente nas tabelas locais Drift.

@ProviderFor(dashboardSummary)
final dashboardSummaryProvider = DashboardSummaryProvider._();

/// Observa os indicadores do dashboard diretamente nas tabelas locais Drift.

final class DashboardSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardSummary>,
          DashboardSummary,
          Stream<DashboardSummary>
        >
    with $FutureModifier<DashboardSummary>, $StreamProvider<DashboardSummary> {
  /// Observa os indicadores do dashboard diretamente nas tabelas locais Drift.
  DashboardSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardSummaryHash();

  @$internal
  @override
  $StreamProviderElement<DashboardSummary> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DashboardSummary> create(Ref ref) {
    return dashboardSummary(ref);
  }
}

String _$dashboardSummaryHash() => r'b93d3cd049361ac0d608d0f725b840e6effaebe1';
