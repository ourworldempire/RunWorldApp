import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final int level;
  final int xp;
  final int xpToNext;
  final int streak;
  final double territoryPercent;
  final double totalDistanceKm;
  final int totalSteps;
  final String? pushToken;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.level,
    required this.xp,
    required this.xpToNext,
    required this.streak,
    required this.territoryPercent,
    required this.totalDistanceKm,
    required this.totalSteps,
    this.pushToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:               json['id'] as String,
    name:             json['name'] as String,
    email:            json['email'] as String,
    avatar:           json['avatar'] as String? ?? '🏃',
    level:            (json['level'] as num?)?.toInt() ?? 1,
    xp:               (json['xp'] as num?)?.toInt() ?? 0,
    xpToNext:         (json['xp_to_next'] as num?)?.toInt() ?? 1000,
    streak:           (json['streak'] as num?)?.toInt() ?? 0,
    territoryPercent: (json['territory_percent'] as num?)?.toDouble() ?? 0.0,
    totalDistanceKm:  (json['total_distance_km'] as num?)?.toDouble() ?? 0.0,
    totalSteps:       (json['total_steps'] as num?)?.toInt() ?? 0,
    pushToken:        json['push_token'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id':               id,
    'name':             name,
    'email':            email,
    'avatar':           avatar,
    'level':            level,
    'xp':               xp,
    'xp_to_next':       xpToNext,
    'streak':           streak,
    'territory_percent': territoryPercent,
    'total_distance_km': totalDistanceKm,
    'total_steps':      totalSteps,
    'push_token':       pushToken,
  };

  String toJsonString() => jsonEncode(toJson());
  factory UserModel.fromJsonString(String s) => UserModel.fromJson(jsonDecode(s) as Map<String, dynamic>);

  UserModel copyWith({
    String? name,
    String? avatar,
    int? level,
    int? xp,
    int? xpToNext,
    int? streak,
    double? territoryPercent,
    double? totalDistanceKm,
    int? totalSteps,
    String? pushToken,
  }) => UserModel(
    id:               id,
    name:             name ?? this.name,
    email:            email,
    avatar:           avatar ?? this.avatar,
    level:            level ?? this.level,
    xp:               xp ?? this.xp,
    xpToNext:         xpToNext ?? this.xpToNext,
    streak:           streak ?? this.streak,
    territoryPercent: territoryPercent ?? this.territoryPercent,
    totalDistanceKm:  totalDistanceKm ?? this.totalDistanceKm,
    totalSteps:       totalSteps ?? this.totalSteps,
    pushToken:        pushToken ?? this.pushToken,
  );

  // Mock user for offline/dev fallback
  static UserModel get mock => const UserModel(
    id:               'mock-user-id',
    name:             'Runner',
    email:            'runner@runworld.app',
    avatar:           '🏃',
    level:            3,
    xp:               420,
    xpToNext:         1690,
    streak:           7,
    territoryPercent: 33.3,
    totalDistanceKm:  42.5,
    totalSteps:       56000,
  );
}
