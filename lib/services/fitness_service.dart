import 'package:dio/dio.dart';
import 'package:runworld/models/user_model.dart';
import 'package:runworld/providers/run_provider.dart';
import 'package:runworld/services/api_service.dart';

class WeeklyStats {
  final List<String> days;
  final List<int>    steps;
  final List<double> distanceKm;
  final List<int>    calories;

  const WeeklyStats({
    required this.days,
    required this.steps,
    required this.distanceKm,
    required this.calories,
  });

  // Backend: GET /fitness/stats/weekly → { days: [{day, steps, distanceKm, calories}], totals }
  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    final raw = (json['days'] as List<dynamic>);
    return WeeklyStats(
      days:       raw.map((d) => d['day']        as String).toList(),
      steps:      raw.map((d) => (d['steps']     as num).toInt()).toList(),
      distanceKm: raw.map((d) => (d['distanceKm'] as num).toDouble()).toList(),
      calories:   raw.map((d) => (d['calories']  as num).toInt()).toList(),
    );
  }

  static WeeklyStats get mock => const WeeklyStats(
    days:       ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    steps:      [7200, 5400, 8900, 3200, 9100, 11200, 6760],
    distanceKm: [5.1,  3.8,  6.3,  2.2,  6.8,  8.1,   5.2],
    calories:   [380,  290,  470,  180,  510,  600,   420],
  );
}

class TodayStats {
  final int    steps;
  final int    stepGoal;
  final double distanceKm;
  final int    calories;
  final int    activeMinutes;

  const TodayStats({
    required this.steps,
    required this.stepGoal,
    required this.distanceKm,
    required this.calories,
    required this.activeMinutes,
  });

  // Backend: GET /fitness/stats/today → { steps, distanceKm, calories, activeMinutes }
  factory TodayStats.fromJson(Map<String, dynamic> json) => TodayStats(
    steps:         (json['steps']          as num).toInt(),
    stepGoal:      10000,                                         // not from backend
    distanceKm:    (json['distanceKm']     as num).toDouble(),
    calories:      (json['calories']       as num).toInt(),
    activeMinutes: (json['activeMinutes']  as num).toInt(),
  );

  static TodayStats get mock => const TodayStats(
    steps: 6760, stepGoal: 10000, distanceKm: 5.2, calories: 420, activeMinutes: 42,
  );
}

class FitnessService {
  FitnessService._();
  static final FitnessService instance = FitnessService._();
  final Dio _dio = ApiService.instance.dio;

  Future<void> saveSession(RunState run, UserModel user) async {
    try {
      await _dio.post('/fitness/sessions', data: {
        'distance_km':      run.distanceKm,
        'steps':            run.steps,
        'calories':         run.calories,
        'xp_earned':        run.xp,
        'duration_seconds': run.elapsedSeconds,
        'activity_type':    run.activityType,
        'path_coordinates': run.pathCoordinates
            .map((p) => {'latitude': p.latitude, 'longitude': p.longitude})
            .toList(),
      });
    } catch (_) {
      // Non-critical — XP already applied locally
    }
  }

  Future<WeeklyStats> getWeeklyStats() async {
    try {
      final resp = await _dio.get('/fitness/stats/weekly');
      return WeeklyStats.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      ApiService.handleException(e);
      return WeeklyStats.mock;
    }
  }

  Future<TodayStats> getTodayStats() async {
    try {
      final resp = await _dio.get('/fitness/stats/today');
      return TodayStats.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      ApiService.handleException(e);
      return TodayStats.mock;
    }
  }

  Future<List<Map<String, dynamic>>> getHistory({int page = 1}) async {
    try {
      final resp = await _dio.get('/fitness/sessions', queryParameters: {
        'limit':  20,
        'offset': (page - 1) * 20,
      });
      return List<Map<String, dynamic>>.from(resp.data['sessions'] as List);
    } catch (_) {
      return [];
    }
  }
}
