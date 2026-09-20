import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/deferred_screens.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/domain/user_model.dart';
import '../../features/auth/presentation/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // 세션 복원(토큰 검증 + 필요 시 리프레시)은 네트워크 상황에 따라
    // 1초보다 오래 걸릴 수 있으므로, 둘 중 더 오래 걸리는 쪽을 기다린다.
    final results = await Future.wait([
      _resolveUser(),
      Future.delayed(const Duration(seconds: 1)),
    ]);
    if (!mounted) return;

    final user = results[0] as UserModel?;
    if (user == null) {
      context.go('/login');
    } else {
      context.go(user.role == 'OWNER' ? '/owner/home' : '/worker/home');
    }
  }

  Future<UserModel?> _resolveUser() async {
    try {
      final user = await ref.read(authStateProvider.future);
      // 역할을 알게 된 즉시 그 역할의 첫 화면 코드를 받아둔다 — 최소 1초 로딩 화면이
      // 어차피 떠 있으므로 그 시간에 겹쳐서 받으면 화면 전환 시 추가 대기가 없다.
      // 실패해도 무시: 실제 화면 진입 시 DeferredScreen이 다시 시도한다.
      if (user != null) {
        await preloadLanding(user.role).catchError((_) {});
      }
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text(
              '로딩중...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
