// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initial_workplaces.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(initialWorkplaces)
final initialWorkplacesProvider = InitialWorkplacesProvider._();

final class InitialWorkplacesProvider
    extends
        $FunctionalProvider<
          InitialWorkplaces,
          InitialWorkplaces,
          InitialWorkplaces
        >
    with $Provider<InitialWorkplaces> {
  InitialWorkplacesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialWorkplacesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialWorkplacesHash();

  @$internal
  @override
  $ProviderElement<InitialWorkplaces> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InitialWorkplaces create(Ref ref) {
    return initialWorkplaces(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InitialWorkplaces value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InitialWorkplaces>(value),
    );
  }
}

String _$initialWorkplacesHash() => r'bd2faed309d10e42531bb74d82508b7c3cbd3abf';
