import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/api_constants.dart';

part 'secure_storage.g.dart';

@riverpod
SecureStorageService secureStorage(Ref ref) {
  return SecureStorageService();
}

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: ApiConstants.tokenKey, value: token);

  Future<String?> getToken() =>
      _storage.read(key: ApiConstants.tokenKey);

  Future<void> deleteToken() =>
      _storage.delete(key: ApiConstants.tokenKey);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: ApiConstants.refreshTokenKey, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: ApiConstants.refreshTokenKey);

  Future<void> deleteRefreshToken() =>
      _storage.delete(key: ApiConstants.refreshTokenKey);

  // 로그아웃 이후에도 로그인 화면에 다시 채워 넣기 위해 토큰과는 별도로 보관한다.
  Future<void> saveLastCredentials(String email, String password) async {
    await _storage.write(key: ApiConstants.lastEmailKey, value: email);
    await _storage.write(key: ApiConstants.lastPasswordKey, value: password);
  }

  Future<String?> getLastEmail() =>
      _storage.read(key: ApiConstants.lastEmailKey);

  Future<String?> getLastPassword() =>
      _storage.read(key: ApiConstants.lastPasswordKey);

  // 근무지별 근로자 달력 색상 커스텀 지정 (팔레트 인덱스만 저장, 이 기기에만 적용됨)
  Future<Map<int, int>> getWorkerColorOverrides(int workplaceId) async {
    final raw = await _storage.read(key: 'worker_color_overrides_$workplaceId');
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
  }

  Future<void> saveWorkerColorOverride(
      int workplaceId, int workerId, int colorIndex) async {
    final current = await getWorkerColorOverrides(workplaceId);
    final updated = {...current, workerId: colorIndex};
    final encoded = jsonEncode(updated.map((k, v) => MapEntry(k.toString(), v)));
    await _storage.write(
        key: 'worker_color_overrides_$workplaceId', value: encoded);
  }

  Future<void> clearAll() => _storage.deleteAll();
}
