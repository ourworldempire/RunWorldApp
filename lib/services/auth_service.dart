import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:runworld/models/user_model.dart';
import 'package:runworld/services/api_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _dio = ApiService.instance.dio;
  final _api = ApiService.instance;
  final _google = GoogleSignIn(scopes: ['email', 'profile']);

  // ── Sign up ────────────────────────────────────────────────────────────────

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String avatar,
  }) async {
    try {
      final resp = await _dio.post('/auth/signup', data: {
        'name':     name,
        'email':    email,
        'password': password,
        'avatar':   avatar,
      });
      final data = resp.data as Map<String, dynamic>;
      await _api.storeTokens(
        access:  data['accessToken']  as String,
        refresh: data['refreshToken'] as String,
      );
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map<String, dynamic>?)?['message'] as String?
          ?? 'Sign up failed';
      throw Exception(msg);
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final resp = await _dio.post('/auth/login', data: {
        'email':    email,
        'password': password,
      });
      final data = resp.data as Map<String, dynamic>;
      await _api.storeTokens(
        access:  data['accessToken']  as String,
        refresh: data['refreshToken'] as String,
      );
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map<String, dynamic>?)?['message'] as String?
          ?? 'Login failed';
      throw Exception(msg);
    }
  }

  // ── Google OAuth ───────────────────────────────────────────────────────────

  Future<UserModel> loginWithGoogle() async {
    try {
      final account = await _google.signIn();
      if (account == null) throw Exception('Google sign-in cancelled');

      final auth = await account.authentication;
      final accessToken = auth.accessToken;
      if (accessToken == null) throw Exception('Failed to get Google access token');

      final resp = await _dio.post('/auth/google', data: {'googleAccessToken': accessToken});
      final data = resp.data as Map<String, dynamic>;
      await _api.storeTokens(
        access:  data['accessToken']  as String,
        refresh: data['refreshToken'] as String,
      );
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map<String, dynamic>?)?['message'] as String?
          ?? 'Google sign-in failed';
      throw Exception(msg);
    }
  }

  // ── Password reset OTP ─────────────────────────────────────────────────────

  Future<void> sendOtp(String email) async {
    try {
      await _dio.post('/auth/forgot-password/send-otp', data: {'email': email});
    } on DioException catch (e) {
      final msg = (e.response?.data as Map<String, dynamic>?)?['message'] as String?
          ?? 'Failed to send OTP';
      throw Exception(msg);
    }
  }

  /// Returns the reset token needed for [resetPassword].
  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final resp = await _dio.post('/auth/forgot-password/verify-otp', data: {
        'email': email,
        'otp':   otp,
      });
      final data = resp.data as Map<String, dynamic>;
      return data['resetToken'] as String;
    } on DioException catch (e) {
      final msg = (e.response?.data as Map<String, dynamic>?)?['message'] as String?
          ?? 'Invalid OTP';
      throw Exception(msg);
    }
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      await _dio.post('/auth/forgot-password/reset', data: {
        'resetToken':  resetToken,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      final msg = (e.response?.data as Map<String, dynamic>?)?['message'] as String?
          ?? 'Password reset failed';
      throw Exception(msg);
    }
  }

  // ── Delete account ─────────────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/auth/account');
    } on DioException catch (e) {
      final msg = (e.response?.data as Map<String, dynamic>?)?['message'] as String?
          ?? 'Failed to delete account';
      throw Exception(msg);
    } finally {
      // Clear local tokens and Google session regardless of server response
      await _api.clearTokens();
      try { await _google.signOut(); } catch (_) {}
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      final refreshToken = await _api.getRefreshToken();
      await _dio.post('/auth/logout', data: refreshToken != null ? {'refreshToken': refreshToken} : null);
    } catch (_) {}
    await _api.clearTokens();
    try {
      await _google.signOut();
    } catch (_) {}
  }
}
