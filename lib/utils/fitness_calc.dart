import 'dart:math';
import 'package:runworld/utils/constants.dart';

// MET formula: Calories = MET × weightKg × durationHours
int calcCalories({
  required String activityType,
  required double weightKg,
  required int durationSeconds,
}) {
  final met = activityType == kActivityRunning ? kMetRunning : kMetWalking;
  final durationHours = durationSeconds / 3600;
  return (weightKg * met * durationHours).round();
}

// Returns "M:SS" pace string (minutes per km)
String calcPace({required double distanceKm, required int durationSeconds}) {
  if (distanceKm <= 0) return '--:--';
  final pace = (durationSeconds / 60) / distanceKm;
  final mins = pace.floor();
  final secs = ((pace - mins) * 60).round();
  return '$mins:${secs.toString().padLeft(2, '0')}';
}

// XP = (duration_minutes × 10) + (distance_km × 20)
int calcXP({required int durationSeconds, required double distanceKm}) {
  final baseXP      = (durationSeconds / 60) * kXpPerMinute;
  final distBonus   = distanceKm * kXpPerKm;
  return (baseXP + distBonus).round();
}

// Haversine distance in meters between two GPS points
double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371000.0; // meters
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) *
      sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double _toRad(double deg) => deg * (pi / 180);

// Format seconds as "H:MM:SS" or "MM:SS"
String formatDuration(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = totalSeconds % 60;
  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

// XP leveling: returns {level, xp, xpToNext} after adding xpEarned
Map<String, int> applyXP({
  required int currentLevel,
  required int currentXP,
  required int currentXpToNext,
  required int xpEarned,
}) {
  int level    = currentLevel;
  int xp       = currentXP + xpEarned;
  int xpToNext = currentXpToNext;

  while (xp >= xpToNext) {
    xp      -= xpToNext;
    level   += 1;
    xpToNext = (xpToNext * kXpLevelMultiplier).round();
  }

  return {'level': level, 'xp': xp, 'xpToNext': xpToNext};
}
