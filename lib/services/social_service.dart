import 'package:dio/dio.dart';
import 'package:runworld/models/user_model.dart';
import 'package:runworld/services/api_service.dart';

class FriendModel {
  final String  id;
  final String  name;
  final String  avatar;
  final int     level;
  final int     streak;
  final double  territoryPercent;

  const FriendModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.level,
    required this.streak,
    required this.territoryPercent,
  });

  // Backend: { id, name, avatar, level, streak, territory_percent }
  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
    id:               json['id']                as String,
    name:             json['name']              as String,
    avatar:           json['avatar']            as String? ?? '🏃',
    level:            (json['level']            as num).toInt(),
    streak:           (json['streak']           as num? ?? 0).toInt(),
    territoryPercent: (json['territory_percent'] as num? ?? 0).toDouble(),
  );

  static List<FriendModel> get mock => const [
    FriendModel(id: 'f1', name: 'Arjun Sharma', avatar: '⚡', level: 8,  streak: 12, territoryPercent: 8.2),
    FriendModel(id: 'f2', name: 'Priya Nair',   avatar: '🌟', level: 5,  streak: 5,  territoryPercent: 4.1),
    FriendModel(id: 'f3', name: 'Karan Mehta',  avatar: '🔥', level: 12, streak: 21, territoryPercent: 15.6),
    FriendModel(id: 'f4', name: 'Sneha Reddy',  avatar: '💎', level: 7,  streak: 9,  territoryPercent: 6.3),
  ];
}

class FriendRequest {
  final String id;        // friendship row id
  final String fromId;
  final String fromName;
  final String fromAvatar;
  final int    fromLevel;

  const FriendRequest({
    required this.id,
    required this.fromId,
    required this.fromName,
    required this.fromAvatar,
    required this.fromLevel,
  });

  // Backend: { id, id (requester profile joined), name, avatar, level }
  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
    id:         json['id']     as String,
    fromId:     json['id']     as String,   // profile id from the JOIN
    fromName:   json['name']   as String,
    fromAvatar: json['avatar'] as String? ?? '🏃',
    fromLevel:  (json['level'] as num).toInt(),
  );

  static List<FriendRequest> get mock => const [
    FriendRequest(id: 'r1', fromId: 'u11', fromName: 'Rahul Gupta',  fromAvatar: '🏆', fromLevel: 6),
    FriendRequest(id: 'r2', fromId: 'u12', fromName: 'Ananya Singh', fromAvatar: '🌙', fromLevel: 4),
  ];
}

class FeedItem {
  final String id;
  final String friendName;
  final String friendAvatar;
  final String type;
  final double distanceKm;
  final int    xpEarned;
  final String when;

  const FeedItem({
    required this.id,
    required this.friendName,
    required this.friendAvatar,
    required this.type,
    required this.distanceKm,
    required this.xpEarned,
    required this.when,
  });

  // Backend: { id, friendName, friendAvatar, type, distanceKm, xpEarned, when }
  factory FeedItem.fromJson(Map<String, dynamic> json) => FeedItem(
    id:           json['id']           as String,
    friendName:   json['friendName']   as String? ?? 'Runner',
    friendAvatar: json['friendAvatar'] as String? ?? '🏃',
    type:         json['type']         as String? ?? 'run',
    distanceKm:   (json['distanceKm'] as num? ?? 0).toDouble(),
    xpEarned:     (json['xpEarned']   as num? ?? 0).toInt(),
    when:         json['when']         as String? ?? '',
  );

  static List<FeedItem> get mock => const [
    FeedItem(id: 'fi1', friendName: 'Karan Mehta',  friendAvatar: '🔥', type: 'run',       distanceKm: 12.4, xpEarned: 168, when: '23m ago'),
    FeedItem(id: 'fi2', friendName: 'Arjun Sharma', friendAvatar: '⚡', type: 'territory', distanceKm: 0.0,  xpEarned: 80,  when: '1h ago'),
    FeedItem(id: 'fi3', friendName: 'Priya Nair',   friendAvatar: '🌟', type: 'run',       distanceKm: 5.1,  xpEarned: 50,  when: '3h ago'),
    FeedItem(id: 'fi4', friendName: 'Karan Mehta',  friendAvatar: '🔥', type: 'run',       distanceKm: 8.1,  xpEarned: 112, when: '8h ago'),
  ];
}

class SocialService {
  SocialService._();
  static final SocialService instance = SocialService._();
  final Dio _dio = ApiService.instance.dio;

  Future<List<FriendModel>> getFriends() async {
    try {
      final resp = await _dio.get('/social/friends');
      return (resp.data['friends'] as List<dynamic>)
          .map((f) => FriendModel.fromJson(f as Map<String, dynamic>))
          .toList();
    } catch (e) {
      ApiService.handleException(e);
      return FriendModel.mock;
    }
  }

  Future<List<FriendRequest>> getFriendRequests() async {
    try {
      final resp = await _dio.get('/social/friends/requests');
      return (resp.data['requests'] as List<dynamic>)
          .map((r) => FriendRequest.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      ApiService.handleException(e);
      return FriendRequest.mock;
    }
  }

  Future<void> sendFriendRequest(String toId) async {
    try {
      await _dio.post('/social/friends/request', data: {'toId': toId});
    } on DioException catch (e) {
      final msg = (e.response?.data as Map<String, dynamic>?)?['message'] as String?
          ?? 'Failed to send request';
      throw Exception(msg);
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _dio.post('/social/friends/accept', data: {'requestId': requestId});
    } catch (_) {}
  }

  Future<void> declineFriendRequest(String requestId) async {
    try {
      await _dio.post('/social/friends/decline', data: {'requestId': requestId});
    } catch (_) {}
  }

  Future<List<FeedItem>> getActivityFeed() async {
    try {
      final resp = await _dio.get('/social/feed');
      return (resp.data['feed'] as List<dynamic>)
          .map((f) => FeedItem.fromJson(f as Map<String, dynamic>))
          .toList();
    } catch (e) {
      ApiService.handleException(e);
      return FeedItem.mock;
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final resp = await _dio.get('/social/profile/$userId');
      return UserModel.fromJson(resp.data['user'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel?> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      final resp = await _dio.put('/social/profile/$userId', data: data);
      return UserModel.fromJson(resp.data['user'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final resp = await _dio.get('/social/search', queryParameters: {'query': query});
      return (resp.data['users'] as List<dynamic>)
          .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
