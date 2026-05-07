class FriendModel {
  final String id;
  final String name;
  final String avatar;
  final int level;
  final int streak;
  final double territoryPercent;

  const FriendModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.level,
    required this.streak,
    required this.territoryPercent,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
    id:               json['id'] as String,
    name:             json['name'] as String,
    avatar:           json['avatar'] as String? ?? '🏃',
    level:            (json['level'] as num?)?.toInt() ?? 1,
    streak:           (json['streak'] as num?)?.toInt() ?? 0,
    territoryPercent: (json['territory_percent'] as num?)?.toDouble() ?? 0.0,
  );
}

class FriendRequestModel {
  final String requestId;
  final String id;
  final String name;
  final String avatar;
  final int level;

  const FriendRequestModel({
    required this.requestId,
    required this.id,
    required this.name,
    required this.avatar,
    required this.level,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) =>
      FriendRequestModel(
        requestId: json['id'] as String,
        id:        json['id'] as String,
        name:      json['name'] as String,
        avatar:    json['avatar'] as String? ?? '🏃',
        level:     (json['level'] as num?)?.toInt() ?? 1,
      );
}

class FeedItemModel {
  final String id;
  final String friendName;
  final String friendAvatar;
  final String type;
  final double distanceKm;
  final int xpEarned;
  final DateTime when;

  const FeedItemModel({
    required this.id,
    required this.friendName,
    required this.friendAvatar,
    required this.type,
    required this.distanceKm,
    required this.xpEarned,
    required this.when,
  });

  factory FeedItemModel.fromJson(Map<String, dynamic> json) => FeedItemModel(
    id:           json['id'] as String,
    friendName:   json['friendName'] as String,
    friendAvatar: json['friendAvatar'] as String? ?? '🏃',
    type:         json['type'] as String,
    distanceKm:   (json['distanceKm'] as num).toDouble(),
    xpEarned:     (json['xpEarned'] as num).toInt(),
    when:         DateTime.parse(json['when'] as String),
  );
}
