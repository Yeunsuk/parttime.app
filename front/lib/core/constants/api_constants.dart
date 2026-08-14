class ApiConstants {
  // 빌드 시 --dart-define=API_BASE_URL=... 로 주입. 값 안 주면 로컬 개발용 기본값.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String lastEmailKey = 'last_email';
  static const String lastPasswordKey = 'last_password';
}
