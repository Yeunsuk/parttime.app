import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/workplace_repository.dart';
import '../domain/workplace_model.dart';

part 'workplace_provider.g.dart';

// 내 근무지 목록
@riverpod
class MyWorkplaces extends _$MyWorkplaces {
  @override
  Future<List<WorkplaceModel>> build() async {
    return ref.read(workplaceRepositoryProvider).getMyWorkplaces();
  }

  Future<void> create(String name, int hourlyWage) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(workplaceRepositoryProvider);
      await repo.create(name, hourlyWage);
      return repo.getMyWorkplaces();
    });
  }

  Future<void> join(String inviteCode) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(workplaceRepositoryProvider);
      await repo.join(inviteCode);
      return repo.getMyWorkplaces();
    });
  }

  Future<void> updateMemberLimit(int workplaceId, int memberLimit) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(workplaceRepositoryProvider);
      await repo.updateMemberLimit(workplaceId, memberLimit);
      return repo.getMyWorkplaces();
    });
  }

  Future<void> updateDisabledHours(int workplaceId, List<int> disabledHours) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(workplaceRepositoryProvider);
      await repo.updateDisabledHours(workplaceId, disabledHours);
      return repo.getMyWorkplaces();
    });
  }

  Future<void> updateEnabledMinutes(int workplaceId, List<int> enabledMinutes) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(workplaceRepositoryProvider);
      await repo.updateEnabledMinutes(workplaceId, enabledMinutes);
      return repo.getMyWorkplaces();
    });
  }
}

// 근무지 소속 근로자 목록 (사장 전용)
@riverpod
Future<List<WorkerModel>> workplaceWorkers(
  Ref ref,
  int workplaceId,
) async {
  return ref.read(workplaceRepositoryProvider).getWorkers(workplaceId);
}

// 직원 추가/퇴장/기본시간/정산기간 설정 (사장 전용). 성공하면 근로자 목록(workplaceWorkers)을
// 다시 불러오게 한다.
// keepAlive: true — 이 notifier는 어디서도 watch되지 않고 액션 실행용으로만 read되는데,
// autoDispose(기본값)이면 리스너가 없어 요청 중에 바로 폐기되어 응답이 왔을 때
// "이미 폐기된 provider" 에러가 나면서 이후 코드(성공 시 invalidate 등)가 통째로 실행되지
// 않는 문제가 있었다. keepAlive로 고정해서 응답을 받을 때까지 살아있게 한다.
@Riverpod(keepAlive: true)
class MemberManagement extends _$MemberManagement {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> addMember(int workplaceId, String employeeId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(workplaceRepositoryProvider).addMember(workplaceId, employeeId),
    );
    _invalidateIfSuccess(workplaceId);
  }

  Future<void> removeMember(int workplaceId, int workerId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(workplaceRepositoryProvider).removeMember(workplaceId, workerId),
    );
    _invalidateIfSuccess(workplaceId);
  }

  Future<void> updateDefaultTime(
    int workplaceId,
    int workerId,
    int clockInHour,
    int clockInMinute,
    int clockOutHour,
    int clockOutMinute,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(workplaceRepositoryProvider).updateDefaultTime(
          workplaceId, workerId, clockInHour, clockInMinute, clockOutHour, clockOutMinute),
    );
    _invalidateIfSuccess(workplaceId);
  }

  Future<void> updatePayPeriod(
      int workplaceId, int workerId, int payPeriodStartDay) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(workplaceRepositoryProvider)
          .updatePayPeriod(workplaceId, workerId, payPeriodStartDay),
    );
    _invalidateIfSuccess(workplaceId);
  }

  Future<void> updatePaymentType(
      int workplaceId, int workerId, String paymentType) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(workplaceRepositoryProvider)
          .updatePaymentType(workplaceId, workerId, paymentType),
    );
    _invalidateIfSuccess(workplaceId);
  }

  Future<void> updateWorkingDays(
      int workplaceId, int workerId, bool enabled, List<int> days) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(workplaceRepositoryProvider)
          .updateWorkingDays(workplaceId, workerId, enabled, days),
    );
    _invalidateIfSuccess(workplaceId);
  }

  void _invalidateIfSuccess(int workplaceId) {
    if (!state.hasError) {
      ref.invalidate(workplaceWorkersProvider);
    }
  }
}

// 근무지가 2개 이상일 때, 사용자가 직접 고른 "현재 근무지" id
@riverpod
class SelectedWorkplaceId extends _$SelectedWorkplaceId {
  @override
  int? build() => null;

  void select(int? workplaceId) => state = workplaceId;
}

// workplaces가 1개면 그것을, 2개 이상이면 selectedId와 일치하는 것을 반환한다.
// (없거나 아직 선택되지 않았으면 null — 선택 UI를 보여줘야 한다는 뜻)
WorkplaceModel? resolveWorkplace(List<WorkplaceModel> workplaces, int? selectedId) {
  if (workplaces.isEmpty) return null;
  if (workplaces.length == 1) return workplaces.first;
  final matches = workplaces.where((w) => w.id == selectedId);
  return matches.isEmpty ? null : matches.first;
}
