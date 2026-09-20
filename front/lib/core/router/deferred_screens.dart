import 'package:flutter/material.dart';
import '../../shared/widgets/deferred_screen.dart';
import 'owner_screens.dart' deferred as owner;
import 'worker_screens.dart' deferred as worker;

// 로그인/회원가입/스플래시만 첫 번들에 넣고, 역할별 화면은 전부 여기서 지연 로딩한다.
// 사장은 근로자 화면을, 근로자는 사장 화면을 받을 일이 없다. 분리 지점을 역할당 하나로
// 묶은 이유: deferred import마다 조각 파일이 따로 생겨서, 화면별로 나누면 요청 수만
// 늘고(27개) 어차피 첫 화면 직후 전부 받게 되므로 얻는 게 없다.

// 스플래시가 역할을 알아낸 직후 그 역할의 화면 코드를 미리 받아두기 위한 진입점.
Future<void> preloadLanding(String role) =>
    role == 'OWNER' ? owner.loadLibrary() : worker.loadLibrary();

Widget ownerHomeScreen() => DeferredScreen(
      load: () => owner.loadLibrary(),
      builder: (_) => owner.OwnerHomeScreen(),
    );

Widget workerDetailScreen({
  required int workplaceId,
  required int workerId,
  required String workerName,
  required int year,
  required int month,
}) =>
    DeferredScreen(
      load: () => owner.loadLibrary(),
      builder: (_) => owner.WorkerDetailScreen(
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
      load: () => owner.loadLibrary(),
      builder: (_) => owner.SettlementScreen(
        workplaceId: workplaceId,
        workplaceName: workplaceName,
      ),
    );

Widget workerHomeScreen() => DeferredScreen(
      load: () => worker.loadLibrary(),
      builder: (_) => worker.WorkerHomeScreen(),
    );

Widget workerCalendarScreen() => DeferredScreen(
      load: () => worker.loadLibrary(),
      builder: (_) => worker.WorkerCalendarScreen(),
    );

Widget workplaceScreen() => DeferredScreen(
      load: () => worker.loadLibrary(),
      builder: (_) => worker.WorkplaceScreen(),
    );
