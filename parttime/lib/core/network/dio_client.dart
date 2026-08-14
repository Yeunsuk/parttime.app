import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

part 'dio_client.g.dart';

@riverpod
Dio dioClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final storage = ref.read(secureStorageProvider);

  // 동시에 여러 요청이 401을 받아도 리프레시는 한 번만 수행되도록 진행 중인
  // Future를 공유한다. 실패하면 두 토큰을 모두 지워 완전 로그아웃 상태로 만든다.
  Future<String?>? refreshFuture;
  Future<String?> refreshAccessToken() {
    return refreshFuture ??= () async {
      try {
        final refreshToken = await storage.getRefreshToken();
        if (refreshToken == null) return null;

        final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
        final res = await refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );
        // 이 요청은 아래 dio.interceptors의 봉투 언랩을 거치지 않으므로 직접 언랩한다.
        final body = res.data as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String;
        await storage.saveToken(newAccessToken);
        await storage.saveRefreshToken(newRefreshToken);
        return newAccessToken;
      } catch (_) {
        await storage.deleteToken();
        await storage.deleteRefreshToken();
        return null;
      }
    }().whenComplete(() => refreshFuture = null);
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      // 백엔드는 모든 응답을 ApiResponse { success, data, message }로 감싸서 보낸다.
      // 각 *_api.dart가 res.data를 페이로드 그 자체로 읽으므로, 여기서 한 번만 벗겨낸다.
      onResponse: (response, handler) {
        final body = response.data;
        if (body is Map<String, dynamic> && body.containsKey('data')) {
          response.data = body['data'];
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        final isUnauthorized = error.response?.statusCode == 401;
        final alreadyRetried = error.requestOptions.extra['retried'] == true;

        if (!isUnauthorized || alreadyRetried) {
          handler.next(error);
          return;
        }

        final newAccessToken = await refreshAccessToken();
        if (newAccessToken == null) {
          handler.next(error);
          return;
        }

        try {
          final retryOptions = error.requestOptions;
          retryOptions.extra['retried'] = true;
          handler.resolve(await dio.fetch(retryOptions));
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      },
    ),
  );

  return dio;
}
