import 'package:runworld/services/api_service.dart';

class EarnedBadge {
  final String badgeId;
  final DateTime earnedAt;
  const EarnedBadge({required this.badgeId, required this.earnedAt});

  factory EarnedBadge.fromJson(Map<String, dynamic> j) => EarnedBadge(
        badgeId:  j['badge_id'] as String,
        earnedAt: DateTime.parse(j['earned_at'] as String),
      );
}

class AchievementsService {
  AchievementsService._();
  static final instance = AchievementsService._();

  // Returns earned badges for the current user.
  Future<List<EarnedBadge>> getMyAchievements() async {
    try {
      final res = await ApiService.instance.dio.get('/achievements');
      final list = res.data['achievements'] as List<dynamic>;
      ApiService.isOffline = false;
      return list.map((e) => EarnedBadge.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      ApiService.handleException(e);
      return [];
    }
  }

  // Returns earned badges for any user (for profile viewing).
  Future<List<EarnedBadge>> getUserAchievements(String userId) async {
    try {
      final res = await ApiService.instance.dio.get('/achievements/user/$userId');
      final list = res.data['achievements'] as List<dynamic>;
      return list.map((e) => EarnedBadge.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      ApiService.handleException(e);
      return [];
    }
  }
}
