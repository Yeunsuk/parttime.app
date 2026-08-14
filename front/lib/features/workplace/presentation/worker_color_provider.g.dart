// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_color_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WorkerColorOverrides)
final workerColorOverridesProvider = WorkerColorOverridesFamily._();

final class WorkerColorOverridesProvider
    extends $AsyncNotifierProvider<WorkerColorOverrides, Map<int, int>> {
  WorkerColorOverridesProvider._({
    required WorkerColorOverridesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'workerColorOverridesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workerColorOverridesHash();

  @override
  String toString() {
    return r'workerColorOverridesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WorkerColorOverrides create() => WorkerColorOverrides();

  @override
  bool operator ==(Object other) {
    return other is WorkerColorOverridesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workerColorOverridesHash() =>
    r'40236ff7b6ca4741eeda55187e2337e3273e2368';

final class WorkerColorOverridesFamily extends $Family
    with
        $ClassFamilyOverride<
          WorkerColorOverrides,
          AsyncValue<Map<int, int>>,
          Map<int, int>,
          FutureOr<Map<int, int>>,
          int
        > {
  WorkerColorOverridesFamily._()
    : super(
        retry: null,
        name: r'workerColorOverridesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkerColorOverridesProvider call(int workplaceId) =>
      WorkerColorOverridesProvider._(argument: workplaceId, from: this);

  @override
  String toString() => r'workerColorOverridesProvider';
}

abstract class _$WorkerColorOverrides extends $AsyncNotifier<Map<int, int>> {
  late final _$args = ref.$arg as int;
  int get workplaceId => _$args;

  FutureOr<Map<int, int>> build(int workplaceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Map<int, int>>, Map<int, int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Map<int, int>>, Map<int, int>>,
              AsyncValue<Map<int, int>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
