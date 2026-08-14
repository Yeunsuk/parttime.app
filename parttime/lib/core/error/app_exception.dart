class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super(message: '인증이 만료되었습니다. 다시 로그인해주세요.');
}

class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}
