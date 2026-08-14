import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      return await ref.read(authStateProvider.future);
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
