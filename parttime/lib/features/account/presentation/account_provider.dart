import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/account_repository.dart';
import '../domain/account_model.dart';

part 'account_provider.g.dart';

// 근무지 계좌 목록 (사장 전용)
@riverpod
Future<List<AccountModel>> workplaceAccounts(Ref ref, int workplaceId) async {
  return ref.read(accountRepositoryProvider).getAccounts(workplaceId);
}

// 계좌 추가/QR등록/삭제 (사장 전용). 성공하면 계좌 목록(workplaceAccounts)을 다시 불러오게 한다.
// keepAlive: true — 액션 실행용으로만 read되는 notifier가 autoDispose면 응답을 받기 전에
// 폐기되어 성공 후 처리가 통째로 날아가는 문제가 있어(다른 *Management notifier와 동일한 이유),
// keepAlive로 고정한다.
@Riverpod(keepAlive: true)
class AccountManagement extends _$AccountManagement {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> create(
    int workplaceId,
    String accountName,
    String accountNumber,
    String bankName,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(accountRepositoryProvider)
          .create(workplaceId, accountName, accountNumber, bankName),
    );
    _invalidateIfSuccess(workplaceId);
  }

  Future<void> addQr(
      int workplaceId, int accountId, String name, String qrImage) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(accountRepositoryProvider).addQr(workplaceId, accountId, name, qrImage),
    );
    _invalidateIfSuccess(workplaceId);
  }

  Future<void> deleteQr(int workplaceId, int accountId, int qrId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(accountRepositoryProvider).deleteQr(workplaceId, accountId, qrId),
    );
    _invalidateIfSuccess(workplaceId);
  }

  Future<void> delete(int workplaceId, int accountId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(accountRepositoryProvider).delete(workplaceId, accountId),
    );
    _invalidateIfSuccess(workplaceId);
  }

  void _invalidateIfSuccess(int workplaceId) {
    if (!state.hasError) {
      ref.invalidate(workplaceAccountsProvider);
    }
  }
}
