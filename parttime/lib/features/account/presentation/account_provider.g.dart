// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workplaceAccounts)
final workplaceAccountsProvider = WorkplaceAccountsFamily._();

final class WorkplaceAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AccountModel>>,
          List<AccountModel>,
          FutureOr<List<AccountModel>>
        >
    with
        $FutureModifier<List<AccountModel>>,
        $FutureProvider<List<AccountModel>> {
  WorkplaceAccountsProvider._({
    required WorkplaceAccountsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'workplaceAccountsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workplaceAccountsHash();

  @override
  String toString() {
    return r'workplaceAccountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AccountModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AccountModel>> create(Ref ref) {
    final argument = this.argument as int;
    return workplaceAccounts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkplaceAccountsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workplaceAccountsHash() => r'50adb3f6e5aff14d2ff0bd750ee6da4dc82ca3b5';

final class WorkplaceAccountsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AccountModel>>, int> {
  WorkplaceAccountsFamily._()
    : super(
        retry: null,
        name: r'workplaceAccountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkplaceAccountsProvider call(int workplaceId) =>
      WorkplaceAccountsProvider._(argument: workplaceId, from: this);

  @override
  String toString() => r'workplaceAccountsProvider';
}

@ProviderFor(AccountManagement)
final accountManagementProvider = AccountManagementProvider._();

final class AccountManagementProvider
    extends $NotifierProvider<AccountManagement, AsyncValue<void>> {
  AccountManagementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountManagementProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountManagementHash();

  @$internal
  @override
  AccountManagement create() => AccountManagement();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$accountManagementHash() => r'641d6c33d1d4b23a532c657a2467f2bf25fa58af';

abstract class _$AccountManagement extends $Notifier<AsyncValue<void>> {
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
