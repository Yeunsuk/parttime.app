// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(payrollRepository)
final payrollRepositoryProvider = PayrollRepositoryProvider._();

final class PayrollRepositoryProvider
    extends
        $FunctionalProvider<
          PayrollRepository,
          PayrollRepository,
          PayrollRepository
        >
    with $Provider<PayrollRepository> {
  PayrollRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'payrollRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$payrollRepositoryHash();

  @$internal
  @override
  $ProviderElement<PayrollRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PayrollRepository create(Ref ref) {
    return payrollRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PayrollRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PayrollRepository>(value),
    );
  }
}

String _$payrollRepositoryHash() => r'c7d6e7eefb5d9c63a59d29595eef78af1b31e9bc';
