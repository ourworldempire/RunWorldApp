import 'package:dio/dio.dart';
import 'package:runworld/models/leaderboard_entry_model.dart';
import 'package:runworld/services/api_service.dart';

class LeaderboardService {
  LeaderboardService._();
  static final LeaderboardService instance = LeaderboardService._();
  final Dio _dio = ApiService.instance.dio;

  // Backend period values: 'week' | 'all'
  String _period(int index) => index == 0 ? 'week' : 'all';

  List<LeaderboardEntryModel> _parse(dynamic resp, String? currentUserId) {
    final list = (resp as Map<String, dynamic>)['entries'] as List<dynamic>;
    return list
        .map((e) => LeaderboardEntryModel.fromJson({
              ...(e as Map<String, dynamic>),
              'isYou': e['id'] == currentUserId,
            }))
        .toList();
  }

  Future<List<LeaderboardEntryModel>> getCityLeaderboard({
    int periodIndex = 0,
    String? currentUserId,
  }) async {
    try {
      final resp = await _dio.get('/leaderboard/city',
          queryParameters: {'period': _period(periodIndex)});
      return _parse(resp.data, currentUserId);
    } catch (e) {
      ApiService.handleException(e);
      return LeaderboardEntryModel.mockList;
    }
  }

  Future<List<LeaderboardEntryModel>> getFriendsLeaderboard({
    int periodIndex = 0,
    String? currentUserId,
  }) async {
    try {
      final resp = await _dio.get('/leaderboard/friends',
          queryParameters: {'period': _period(periodIndex)});
      return _parse(resp.data, currentUserId);
    } catch (e) {
      ApiService.handleException(e);
      return LeaderboardEntryModel.mockList.take(3).toList();
    }
  }

  Future<List<LeaderboardEntryModel>> getNearbyLeaderboard({
    String? currentUserId,
  }) async {
    try {
      final resp = await _dio.get('/leaderboard/nearby');
      return _parse(resp.data, currentUserId);
    } catch (e) {
      ApiService.handleException(e);
      return LeaderboardEntryModel.mockList;
    }
  }
}
