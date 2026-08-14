import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/error/app_exception.dart';
import '../domain/user_model.dart';
import 'auth_api.dart';
import 'package:dio/dio.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(AuthApi(dio), storage);
}

class AuthRepository {
  final AuthApi _api;
  final SecureStorageService _storage;

  AuthRepository(this._api, this._storage);

  Future<UserModel> login(String email, String password) async {
    try {
      final res = await _api.login(email, password);
      await _storage.saveToken(res.accessToken);
      await _storage.saveRefreshToken(res.refreshToken);
      await _storage.saveLastCredentials(email, password);
      return res.user;
    } on DioException catch (e) {
      throw _authError(e);
    }
  }

  Future<UserModel> signup(String email, String password, String name,
      String role, String? ownerAuthCode) async {
    try {
      final res = await _api.signup(email, password, name, role, ownerAuthCode);
      await _storage.saveToken(res.accessToken);
      await _storage.saveRefreshToken(res.refreshToken);
      await _storage.saveLastCredentials(email, password);
      return res.user;
    } on DioException catch (e) {
      throw _authError(e);
    }
  }

  // 마지막으로 로그인했던 이메일/비밀번호는 로그아웃해도 로그인 화면에 남아있어야
  // 하므로 clearAll() 대신 세션 토큰만 지운다.
  Future<void> logout() async {
    await _storage.deleteToken();
    await _storage.deleteRefreshToken();
  }

  Future<UserModel> getMe() async {
    try {
      return await _api.getMe();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    if (_isConnectionError(e)) {
      return const NetworkException(message: '네트워크 연결을 확인해주세요.');
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return const UnauthorizedException();
    final message = e.response?.data?['message'] as String? ?? e.message ?? '알 수 없는 오류';
    return ServerException(message: message, statusCode: statusCode);
  }

  // 로그인/회원가입은 아직 세션이 없는 상태에서 호출하는 공개 엔드포인트라, 401이 나도
  // "세션 만료"가 아니라 서버가 내려준 실제 사유(예: 비밀번호 불일치)를 그대로 보여줘야 한다.
  AppException _authError(DioException e) {
    if (_isConnectionError(e)) {
      return const NetworkException(message: '네트워크 연결을 확인해주세요.');
    }
    final message = e.response?.data?['message'] as String? ?? e.message ?? '알 수 없는 오류';
    return ServerException(message: message, statusCode: e.response?.statusCode);
  }

  bool _isConnectionError(DioException e) =>
      e.response == null &&
      (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown);
}
