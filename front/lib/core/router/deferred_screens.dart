import 'package:flutter/material.dart';
import 'package:parttime/features/work_record/presentation/worker_home_screen.dart'
    deferred as worker_home;
import '../../features/payroll/presentation/owner_home_screen.dart'
    deferred as owner_home;
import '../../features/payroll/presentation/settlement_screen.dart'
    deferred as settlement;
import '../../features/payroll/presentation/worker_detail_screen.dart'
    deferred as worker_detail;
import '../../features/work_record/presentation/worker_calendar_screen.dart'
    deferred as worker_calendar;
import '../../features/workplace/presentation/workplace_screen.dart'
    deferred as workplace;
import '../../shared/widgets/deferred_screen.dart';

// 로그인/회원가입/스플래시만 첫 번들에 넣고, 역할별 화면은 전부 여기서 지연 로딩한다.
// 사장은 근로자 화면을, 근로자는 사장 화면을 받을 일이 없다.

// 스플래시가 역할을 알아낸 직후 랜딩 화면을 미리 받아두기 위한 진입점.
Future<void> preloadLanding(String role) => role == 'OWNER'
    ? owner_home.loadLibrary()
    : worker_home.loadLibrary();

Widget ownerHomeScreen() => DeferredScreen(
      load: () => owner_home.loadLibrary(),
      prefetch: [
        () => settlement.loadLibrary(),
        () => worker_detail.loadLibrary(),
      ],
      builder: (_) => owner_home.OwnerHomeScreen(),
    );

Widget workerHomeScreen() => DeferredScreen(
      load: () => worker_home.loadLibrary(),
      prefetch: [
        () => worker_calendar.loadLibrary(),
        () => workplace.loadLibrary(),
      ],
      builder: (_) => worker_home.WorkerHomeScreen(),
    );

Widget workerCalendarScreen() => DeferredScreen(
      load: () => worker_calendar.loadLibrary(),
      builder: (_) => worker_calendar.WorkerCalendarScreen(),
    );

Widget workplaceScreen() => DeferredScreen(
      load: () => workplace.loadLibrary(),
      builder: (_) => workplace.WorkplaceScreen(),
    );

Widget workerDetailScreen({
  required int workplaceId,
  required int workerId,
  required String workerName,
  required int year,
  required int month,
}) =>
    DeferredScreen(
      load: () => worker_detail.loadLibrary(),
      builder: (_) => worker_detail.WorkerDetailScreen(
        workplaceId: workplaceId,
        workerId: workerId,
        workerName: workerName,
        year: year,
        month: month,
      ),
    );

Widget settlementScreen({
  required int workplaceId,
  required String workplaceName,
}) =>
    DeferredScreen(
      load: () => settlement.loadLibrary(),
      builder: (_) => settlement.SettlementScreen(
        workplaceId: workplaceId,
        workplaceName: workplaceName,
      ),
    );
