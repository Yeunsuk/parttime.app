import 'package:dio/dio.dart';
import '../domain/user_model.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<AuthResponse> login(String email, String password) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthResponse> signup(String email, String password, String name,
      String role, String? ownerAuthCode) async {
    final res = await _dio.post(
      '/auth/signup',
      data: {
        'email': email,
        'password': password,
        'name': name,
        'role': role,
        'ownerAuthCode': ownerAuthCode,
      },
    );
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserModel> getMe() async {
    final res = await _dio.get('/auth/me');
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}
