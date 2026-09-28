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
         isAutoDispose: false,
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

String _$workplaceRecordsHash() => r'c01dc623548441550170d5f21f65454b10189bac';

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
        isAutoDispose: false,
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
         isAutoDispose: false,
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

String _$workerDetailHash() => r'6b0e7b1afdedcc2fa7d6a460c32de4d8e1f399f2';

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
        isAutoDispose: false,
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
         isAutoDispose: false,
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

String _$settlementHash() => r'8b7db0b1f3d6c787718d34b34d755594190de353';

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
        isAutoDispose: false,
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

String _$recordModifyHash() => r'01fcd02a3fac806db36c5d687234231a29d18403';

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
