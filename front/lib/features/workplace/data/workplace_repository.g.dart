// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workplaceRepository)
final workplaceRepositoryProvider = WorkplaceRepositoryProvider._();

final class WorkplaceRepositoryProvider
    extends
        $FunctionalProvider<
          WorkplaceRepository,
          WorkplaceRepository,
          WorkplaceRepository
        >
    with $Provider<WorkplaceRepository> {
  WorkplaceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workplaceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workplaceRepositoryHash();

  @$internal
  @override
  $ProviderElement<WorkplaceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkplaceRepository create(Ref ref) {
    return workplaceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkplaceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkplaceRepository>(value),
    );
  }
}

String _$workplaceRepositoryHash() =>
    r'1d743f58e5715783dee3363e74c6758e7bba8d30';
