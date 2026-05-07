import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:runworld/config/app_config.dart';

const _kAccessKey  = 'runworld_access_token';
const _kRefreshKey = 'runworld_refresh_token';

class ApiService {
  ApiService._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _kAccessKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        isOffline = false;
        handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            // Retry original request with new token
            final newToken = await _storage.read(key: _kAccessKey);
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';
            try {
              final resp = await _dio.fetch(opts);
              handler.resolve(resp);
              return;
            } catch (_) {}
          }
          // Refresh failed — clear tokens
          await clearTokens();
        }
        handler.next(error);
      },
    ));
  }

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  static final ApiService instance = ApiService._();
  Dio get dio => _dio;

  // Set to true when the last service call failed due to a network error.
  // Cleared to false on any successful response (via interceptor).
  static bool isOffline = false;

  static void handleException(dynamic e) {
    if (e is DioException) {
      isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
    }
  }

  Future<bool> _tryRefresh() async {
    try {
      final refreshToken = await _storage.read(key: _kRefreshKey);
      if (refreshToken == null) return false;

      // Use a plain Dio (no interceptor) to avoid infinite loop
      final resp = await Dio().post(
        '${AppConfig.apiBaseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = resp.data as Map<String, dynamic>;
      await storeTokens(
        access:  data['accessToken']  as String,
        refresh: data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> storeTokens({required String access, required String refresh}) async {
    await Future.wait([
      _storage.write(key: _kAccessKey,  value: access),
      _storage.write(key: _kRefreshKey, value: refresh),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _kAccessKey),
      _storage.delete(key: _kRefreshKey),
    ]);
  }

  Future<String?> getAccessToken()  => _storage.read(key: _kAccessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshKey);
}
