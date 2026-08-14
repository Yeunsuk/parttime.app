import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/account/presentation/account_popup_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/auth_provider.dart';
import 'package:parttime/features/work_record/presentation/worker_home_screen.dart';
import '../../features/work_record/presentation/worker_calendar_screen.dart';
import '../../features/payroll/presentation/owner_home_screen.dart';
import '../../features/payroll/presentation/settlement_screen.dart';
import '../../features/payroll/presentation/worker_detail_screen.dart';
import '../../features/workplace/presentation/workplace_screen.dart';
import '../../shared/widgets/splash_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  // go_router는 initialLocation이 지정되어 있으면 웹에서도 실제 브라우저 주소(해시)
  // 대신 그 값을 그대로 첫 화면으로 써버린다. 그래서 이걸 고정 '/splash'로 두면 계좌
  // 팝업 창처럼 앱을 처음부터 띄우며 특정 화면으로 바로 가야 하는 경우 항상 /splash를
  // 거치게 되어(=다시 로그인 과정을 타게 되어) 의미가 없어진다. 팝업이 열어준 주소가
  // /account-popup일 때만 그 주소를 그대로 시작 위치로 쓰고, 그 외에는 기존처럼 항상
  // /splash에서 시작해 로그인 상태 복원을 거치게 한다.
  final currentFragment = Uri.base.fragment;
  final initialLocation = currentFragment.startsWith('/account-popup')
      ? currentFragment
      : '/splash';

  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final isSplash = state.matchedLocation == '/splash';
      // 계좌 팝업 창은 URL에 담아 넘긴 데이터만 그대로 보여줄 뿐 로그인이나 API 호출이
      // 전혀 필요 없어서, 인증 여부와 무관하게 항상 접근 가능해야 한다.
      final isAccountPopup = state.matchedLocation == '/account-popup';

      if (isSplash || isAccountPopup) return null;
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) {
        final role = authState.value!.role;
        return role == 'OWNER' ? '/owner/home' : '/worker/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash',           builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login',            builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/signup',           builder: (_, _) => const SignupScreen()),
      GoRoute(path: '/worker/home',      builder: (_, _) => const WorkerHomeScreen()),
      GoRoute(path: '/worker/calendar',  builder: (_, _) => const WorkerCalendarScreen()),
      GoRoute(path: '/worker/workplace', builder: (_, _) => const WorkplaceScreen()),
      GoRoute(path: '/owner/home',       builder: (_, _) => const OwnerHomeScreen()),
      GoRoute(
        path: '/owner/worker-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return WorkerDetailScreen(
            workplaceId: extra['workplaceId'] as int,
            workerId: extra['workerId'] as int,
            workerName: extra['workerName'] as String,
            year: extra['year'] as int,
            month: extra['month'] as int,
          );
        },
      ),
      GoRoute(
        path: '/owner/settlement',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return SettlementScreen(
            workplaceId: extra['workplaceId'] as int,
            workplaceName: extra['workplaceName'] as String,
          );
        },
      ),
      GoRoute(
        // 로그인 없이도 열리는 계좌 팝업 창 전용 화면. 데이터는 API 호출 없이
        // URL 쿼리 파라미터(data)에 그대로 담아 전달받는다.
        path: '/account-popup',
        builder: (context, state) {
          final workplaceName = state.uri.queryParameters['workplaceName'] ?? '';
          final data = state.uri.queryParameters['data'] ?? '';
          return AccountPopupScreen.fromEncoded(
            workplaceName: workplaceName,
            encoded: data,
          );
        },
      ),
    ],
  );
}
