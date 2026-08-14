// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_record_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workRecordRepository)
final workRecordRepositoryProvider = WorkRecordRepositoryProvider._();

final class WorkRecordRepositoryProvider
    extends
        $FunctionalProvider<
          WorkRecordRepository,
          WorkRecordRepository,
          WorkRecordRepository
        >
    with $Provider<WorkRecordRepository> {
  WorkRecordRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workRecordRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workRecordRepositoryHash();

  @$internal
  @override
  $ProviderElement<WorkRecordRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkRecordRepository create(Ref ref) {
    return workRecordRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkRecordRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkRecordRepository>(value),
    );
  }
}

String _$workRecordRepositoryHash() =>
    r'aea38cb0ac7897cf3e8ef9d4afde1aae2870b719';
