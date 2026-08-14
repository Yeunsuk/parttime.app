import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/work_record_repository.dart';
import '../domain/work_record_model.dart';

part 'work_record_provider.g.dart';

// 현재 출근 상태
@riverpod
class WorkStatus extends _$WorkStatus {
  @override
  Future<WorkStatusModel> build() async {
    return ref.read(workRecordRepositoryProvider).getStatus();
  }

  Future<void> clockIn(int workplaceId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final record = await ref
          .read(workRecordRepositoryProvider)
          .clockIn(workplaceId);
      return WorkStatusModel(isClockedIn: true, currentRecord: record);
    });
  }

  Future<void> clockOut(int recordId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(workRecordRepositoryProvider).clockOut(recordId);
      return const WorkStatusModel(isClockedIn: false, currentRecord: null);
    });
  }
}

// 달력 파라미터 타입
typedef CalendarParam = ({int year, int month});

@riverpod
Future<List<WorkRecordModel>> calendar(
  Ref ref,
  CalendarParam param,
) async {
  return ref
      .read(workRecordRepositoryProvider)
      .getCalendar(param.year, param.month);
}