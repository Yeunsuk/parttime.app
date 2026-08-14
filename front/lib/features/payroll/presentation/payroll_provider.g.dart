// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workplaceRecords)
final workplaceRecordsProvider = WorkplaceRecordsFamily._();

final class WorkplaceRecordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PayrollDetailModel>>,
          List<PayrollDetailModel>,
          FutureOr<List<PayrollDetailModel>>
        >
    with
        $FutureModifier<List<PayrollDetailModel>>,
        $FutureProvider<List<PayrollDetailModel>> {
  WorkplaceRecordsProvider._({
    required WorkplaceRecordsFamily super.from,
    required PayrollParam super.argument,
  }) : super(
         retry: null,
         name: r'workplaceRecordsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workplaceRecordsHash();

  @override
  String toString() {
    return r'workplaceRecordsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PayrollDetailModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PayrollDetailModel>> create(Ref ref) {
    final argument = this.argument as PayrollParam;
    return workplaceRecords(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkplaceRecordsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workplaceRecordsHash() => r'c9b36b2c00790410f3e76d65bbb725c2716f857f';

final class WorkplaceRecordsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PayrollDetailModel>>,
          PayrollParam
        > {
  WorkplaceRecordsFamily._()
    : super(
        retry: null,
        name: r'workplaceRecordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkplaceRecordsProvider call(PayrollParam param) =>
      WorkplaceRecordsProvider._(argument: param, from: this);

  @override
  String toString() => r'workplaceRecordsProvider';
}

@ProviderFor(workerDetail)
final workerDetailProvider = WorkerDetailFamily._();

final class WorkerDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PayrollDetailModel>>,
          List<PayrollDetailModel>,
          FutureOr<List<PayrollDetailModel>>
        >
    with
        $FutureModifier<List<PayrollDetailModel>>,
        $FutureProvider<List<PayrollDetailModel>> {
  WorkerDetailProvider._({
    required WorkerDetailFamily super.from,
    required WorkerDetailParam super.argument,
  }) : super(
         retry: null,
         name: r'workerDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workerDetailHash();

  @override
  String toString() {
    return r'workerDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PayrollDetailModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PayrollDetailModel>> create(Ref ref) {
    final argument = this.argument as WorkerDetailParam;
    return workerDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkerDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workerDetailHash() => r'11986b7a93448ffe83eb8a3ed2d23a9160ddf9a2';

final class WorkerDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PayrollDetailModel>>,
          WorkerDetailParam
        > {
  WorkerDetailFamily._()
    : super(
        retry: null,
        name: r'workerDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkerDetailProvider call(WorkerDetailParam param) =>
      WorkerDetailProvider._(argument: param, from: this);

  @override
  String toString() => r'workerDetailProvider';
}

@ProviderFor(settlement)
final settlementProvider = SettlementFamily._();

final class SettlementProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SettlementModel>>,
          List<SettlementModel>,
          FutureOr<List<SettlementModel>>
        >
    with
        $FutureModifier<List<SettlementModel>>,
        $FutureProvider<List<SettlementModel>> {
  SettlementProvider._({
    required SettlementFamily super.from,
    required PayrollParam super.argument,
  }) : super(
         retry: null,
         name: r'settlementProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$settlementHash();

  @override
  String toString() {
    return r'settlementProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SettlementModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SettlementModel>> create(Ref ref) {
    final argument = this.argument as PayrollParam;
    return settlement(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SettlementProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$settlementHash() => r'd3ba4614dda15926ac63d38a1cc9fd3b6a691388';

final class SettlementFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SettlementModel>>,
          PayrollParam
        > {
  SettlementFamily._()
    : super(
        retry: null,
        name: r'settlementProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SettlementProvider call(PayrollParam param) =>
      SettlementProvider._(argument: param, from: this);

  @override
  String toString() => r'settlementProvider';
}

@ProviderFor(RecordModify)
final recordModifyProvider = RecordModifyProvider._();

final class RecordModifyProvider
    extends $NotifierProvider<RecordModify, AsyncValue<void>> {
  RecordModifyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordModifyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordModifyHash();

  @$internal
  @override
  RecordModify create() => RecordModify();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$recordModifyHash() => r'bd1d81158a9a87b1842e36e765a2585b5063b907';

abstract class _$RecordModify extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
