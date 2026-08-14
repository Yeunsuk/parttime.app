// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyWorkplaces)
final myWorkplacesProvider = MyWorkplacesProvider._();

final class MyWorkplacesProvider
    extends $AsyncNotifierProvider<MyWorkplaces, List<WorkplaceModel>> {
  MyWorkplacesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myWorkplacesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myWorkplacesHash();

  @$internal
  @override
  MyWorkplaces create() => MyWorkplaces();
}

String _$myWorkplacesHash() => r'edbff7201d6e8db4bf66a24ca8b42e25817b92bf';

abstract class _$MyWorkplaces extends $AsyncNotifier<List<WorkplaceModel>> {
  FutureOr<List<WorkplaceModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<WorkplaceModel>>, List<WorkplaceModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<WorkplaceModel>>,
                List<WorkplaceModel>
              >,
              AsyncValue<List<WorkplaceModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(workplaceWorkers)
final workplaceWorkersProvider = WorkplaceWorkersFamily._();

final class WorkplaceWorkersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkerModel>>,
          List<WorkerModel>,
          FutureOr<List<WorkerModel>>
        >
    with
        $FutureModifier<List<WorkerModel>>,
        $FutureProvider<List<WorkerModel>> {
  WorkplaceWorkersProvider._({
    required WorkplaceWorkersFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'workplaceWorkersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workplaceWorkersHash();

  @override
  String toString() {
    return r'workplaceWorkersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WorkerModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkerModel>> create(Ref ref) {
    final argument = this.argument as int;
    return workplaceWorkers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkplaceWorkersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workplaceWorkersHash() => r'6ffdad522cdf641d4694ab517f85ecc355b8d96e';

final class WorkplaceWorkersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WorkerModel>>, int> {
  WorkplaceWorkersFamily._()
    : super(
        retry: null,
        name: r'workplaceWorkersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkplaceWorkersProvider call(int workplaceId) =>
      WorkplaceWorkersProvider._(argument: workplaceId, from: this);

  @override
  String toString() => r'workplaceWorkersProvider';
}

@ProviderFor(MemberManagement)
final memberManagementProvider = MemberManagementProvider._();

final class MemberManagementProvider
    extends $NotifierProvider<MemberManagement, AsyncValue<void>> {
  MemberManagementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberManagementProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberManagementHash();

  @$internal
  @override
  MemberManagement create() => MemberManagement();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$memberManagementHash() => r'cab8e59775cbfc6d95e75dd798ac22ab38b88262';

abstract class _$MemberManagement extends $Notifier<AsyncValue<void>> {
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

@ProviderFor(SelectedWorkplaceId)
final selectedWorkplaceIdProvider = SelectedWorkplaceIdProvider._();

final class SelectedWorkplaceIdProvider
    extends $NotifierProvider<SelectedWorkplaceId, int?> {
  SelectedWorkplaceIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedWorkplaceIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedWorkplaceIdHash();

  @$internal
  @override
  SelectedWorkplaceId create() => SelectedWorkplaceId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$selectedWorkplaceIdHash() =>
    r'c921b9ba6b1ed604171369e7644a4a6db05bdb30';

abstract class _$SelectedWorkplaceId extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
