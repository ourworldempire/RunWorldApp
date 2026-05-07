import 'package:latlong2/latlong.dart';

class RunSessionModel {
  final String? id;
  final String? userId;
  final String activityType;
  final double distanceKm;
  final int durationSeconds;
  final int steps;
  final int calories;
  final int xpEarned;
  final int territoryCaptured;
  final List<LatLng> pathCoordinates;
  final List<String> badgesUnlocked;
  final DateTime? createdAt;

  const RunSessionModel({
    this.id,
    this.userId,
    required this.activityType,
    required this.distanceKm,
    required this.durationSeconds,
    required this.steps,
    required this.calories,
    required this.xpEarned,
    this.territoryCaptured = 0,
    this.pathCoordinates = const [],
    this.badgesUnlocked = const [],
    this.createdAt,
  });

  factory RunSessionModel.fromJson(Map<String, dynamic> json) {
    final rawPath = json['path_coordinates'] as List<dynamic>? ?? [];
    final path = rawPath.map((p) {
      final m = p as Map<String, dynamic>;
      return LatLng(
        (m['latitude'] as num).toDouble(),
        (m['longitude'] as num).toDouble(),
      );
    }).toList();

    final rawBadges = json['badges_unlocked'] as List<dynamic>? ?? [];

    return RunSessionModel(
      id:                  json['id'] as String?,
      userId:              json['user_id'] as String?,
      activityType:        json['activity_type'] as String,
      distanceKm:          (json['distance_km'] as num).toDouble(),
      durationSeconds:     (json['duration_seconds'] as num).toInt(),
      steps:               (json['steps'] as num).toInt(),
      calories:            (json['calories'] as num).toInt(),
      xpEarned:            (json['xp_earned'] as num).toInt(),
      territoryCaptured:   (json['territory_captured'] as num?)?.toInt() ?? 0,
      pathCoordinates:     path,
      badgesUnlocked:      rawBadges.map((e) => e as String).toList(),
      createdAt:           json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'activity_type':      activityType,
    'distance_km':        distanceKm,
    'duration_seconds':   durationSeconds,
    'steps':              steps,
    'calories':           calories,
    'xp_earned':          xpEarned,
    'territory_captured': territoryCaptured,
    'path_coordinates':   pathCoordinates
        .map((p) => {'latitude': p.latitude, 'longitude': p.longitude})
        .toList(),
    'badges_unlocked':    badgesUnlocked,
  };
}
