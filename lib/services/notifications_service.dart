import 'package:dio/dio.dart';
import 'package:runworld/services/api_service.dart';

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();
  final Dio _dio = ApiService.instance.dio;

  // Backend: POST /notifications/register  body: { pushToken }
  Future<void> registerPushToken(String token) async {
    try {
      await _dio.post('/notifications/register', data: {'pushToken': token});
    } catch (_) {}
  }
}
