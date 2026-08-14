import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/storage/secure_storage.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

part 'auth_provider.g.dart';

// 현재 로그인된 유저 상태 (앱 전역)
@riverpod
class AuthState extends _$AuthState {
  @override
  Future<UserModel?> build() async {
    // 앱 시작 시 저장된 토큰으로 세션 복원. 액세스 토큰이 만료됐어도
    // dio 인터셉터가 리프레시 토큰으로 자동 갱신 후 이 호출을 재시도한다.
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getToken();
    if (token == null) return null;

    try {
      return await ref.read(authRepositoryProvider).getMe();
    } on UnauthorizedException {
      // 리프레시 토큰까지 만료/무효 — 세션 토큰만 지운다. 마지막으로 로그인했던
      // 아이디/비밀번호는 로그아웃 때와 마찬가지로 로그인 화면에 남겨둔다.
      await ref.read(authRepositoryProvider).logout();
      return null;
    } on AppException {
      // 네트워크/서버 오류: 토큰은 아직 유효할 수 있으니 지우지 않고
      // 이번 세션만 로그아웃 화면으로 보낸다 (재시도는 다음 콜드 스타트에).
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      ref.read(authRepositoryProvider).login(email, password),
    );
  }

  Future<void> signup(String email, String password, String name, String role,
      [String? ownerAuthCode]) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(authRepositoryProvider)
        .signup(email, password, name, role, ownerAuthCode));
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
