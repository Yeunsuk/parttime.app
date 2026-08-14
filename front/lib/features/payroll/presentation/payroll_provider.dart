import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/payroll_repository.dart';
import '../domain/payroll_model.dart';

part 'payroll_provider.g.dart';

typedef PayrollParam = ({int workplaceId, int year, int month});
typedef WorkerDetailParam = ({
  int workplaceId,
  int workerId,
  int year,
  int month
});

// 근무지 전체 근로자 근무기록 (달력용)
@riverpod
Future<List<PayrollDetailModel>> workplaceRecords(
  Ref ref,
  PayrollParam param,
) async {
  return ref.read(payrollRepositoryProvider).getWorkplaceRecords(
        param.workplaceId,
        param.year,
        param.month,
      );
}

@riverpod
Future<List<PayrollDetailModel>> workerDetail(
  Ref ref,
  WorkerDetailParam param,
) async {
  return ref.read(payrollRepositoryProvider).getWorkerDetail(
        param.workplaceId,
        param.workerId,
        param.year,
        param.month,
      );
}

// 근무지 소속 직원별 정산 (각자 정산기간 기준, 선택된 (year, month)가 속한 기간)
@riverpod
Future<List<SettlementModel>> settlement(Ref ref, PayrollParam param) async {
  return ref
      .read(payrollRepositoryProvider)
      .getSettlement(param.workplaceId, param.year, param.month);
}

// keepAlive: true — 이 notifier는 어디서도 watch되지 않고 액션 실행용으로만 read되는데,
// autoDispose(기본값)이면 리스너가 없어 요청 중에 바로 폐기되어 응답이 왔을 때
// "이미 폐기된 provider" 에러가 나면서 이후 코드(성공 시 invalidate 등)가 통째로 실행되지
// 않는 문제가 있었다. keepAlive로 고정해서 응답을 받을 때까지 살아있게 한다.
@Riverpod(keepAlive: true)
class RecordModify extends _$RecordModify {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> modify(int recordId, String clockIn, String clockOut) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(payrollRepositoryProvider).modifyRecord(recordId, clockIn, clockOut));
    _invalidateIfSuccess();
  }

  Future<void> add(int workplaceId, int workerId, String clockIn,
      String clockOut, [double? recordCount]) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(payrollRepositoryProvider)
        .addRecord(workplaceId, workerId, clockIn, clockOut, recordCount));
    _invalidateIfSuccess();
  }

  Future<void> delete(int recordId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(payrollRepositoryProvider).deleteRecord(recordId));
    _invalidateIfSuccess();
  }

  // 수정/추가/삭제 성공 후 달력 화면들이 캐시된 옛 데이터를 계속 보여주지 않도록 다시 불러오게 한다.
  void _invalidateIfSuccess() {
    if (!state.hasError) {
      ref.invalidate(workerDetailProvider);
      ref.invalidate(workplaceRecordsProvider);
    }
  }
}
