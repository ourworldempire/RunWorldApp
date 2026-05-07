import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pedometer/pedometer.dart';
import 'package:runworld/config/app_config.dart';
import 'package:runworld/utils/fitness_calc.dart';

class RunState {
  final double distanceKm;
  final int steps;
  final int calories;
  final int xp;
  final int elapsedSeconds;
  final bool isRunning;
  final bool isPaused;
  final String activityType;
  final List<LatLng> pathCoordinates;

  const RunState({
    this.distanceKm = 0.0,
    this.steps = 0,
    this.calories = 0,
    this.xp = 0,
    this.elapsedSeconds = 0,
    this.isRunning = false,
    this.isPaused = false,
    this.activityType = 'running',
    this.pathCoordinates = const [],
  });

  RunState copyWith({
    double? distanceKm,
    int? steps,
    int? calories,
    int? xp,
    int? elapsedSeconds,
    bool? isRunning,
    bool? isPaused,
    String? activityType,
    List<LatLng>? pathCoordinates,
  }) => RunState(
    distanceKm:      distanceKm      ?? this.distanceKm,
    steps:           steps           ?? this.steps,
    calories:        calories        ?? this.calories,
    xp:              xp              ?? this.xp,
    elapsedSeconds:  elapsedSeconds  ?? this.elapsedSeconds,
    isRunning:       isRunning       ?? this.isRunning,
    isPaused:        isPaused        ?? this.isPaused,
    activityType:    activityType    ?? this.activityType,
    pathCoordinates: pathCoordinates ?? this.pathCoordinates,
  );
}

class RunNotifier extends StateNotifier<RunState> {
  RunNotifier() : super(const RunState());

  Timer?                       _timer;
  StreamSubscription<Position>?  _gpsSub;
  StreamSubscription<StepCount>? _pedometerSub;

  // Cumulative steps from boot at the moment startRun was called
  int    _stepOffset = 0;
  double _weightKg   = 70.0;  // default; overridden by settings

  // Last known GPS position for haversine diff
  Position? _lastPosition;

  // ── Public API ─────────────────────────────────────────────────────────────

  void setWeight(double kg) => _weightKg = kg;

  void setActivityType(String type) {
    state = state.copyWith(activityType: type);
  }

  Future<void> startRun({String activityType = 'running'}) async {
    state = RunState(isRunning: true, activityType: activityType);
    _lastPosition = null;
    _stepOffset   = 0;
    _startTimer();
    await _startGps();
    _startPedometer();
  }

  void pauseRun() {
    if (!state.isRunning || state.isPaused) return;
    state = state.copyWith(isPaused: true);
    _timer?.cancel();
    _gpsSub?.pause();
  }

  void resumeRun() {
    if (!state.isRunning || !state.isPaused) return;
    state = state.copyWith(isPaused: false);
    _startTimer();
    _gpsSub?.resume();
  }

  /// Capture final state snapshot before resetting.
  RunState stopRun() {
    final snapshot = state;
    _cancelAll();
    state = const RunState();
    return snapshot;
  }

  // ── Timer ──────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isRunning || state.isPaused) return;
      final newElapsed = state.elapsedSeconds + 1;
      final newCalories = calcCalories(
        activityType:    state.activityType,
        weightKg:        _weightKg,
        durationSeconds: newElapsed,
      );
      final newXP = calcXP(
        durationSeconds: newElapsed,
        distanceKm:      state.distanceKm,
      );
      state = state.copyWith(
        elapsedSeconds: newElapsed,
        calories:       newCalories,
        xp:             newXP,
      );
    });
  }

  // ── GPS ────────────────────────────────────────────────────────────────────

  Future<void> _startGps() async {
    final locationSettings = AndroidSettings(
      accuracy:       LocationAccuracy.high,
      distanceFilter: AppConfig.gpsDistanceFilterMeters,
      intervalDuration: const Duration(milliseconds: AppConfig.gpsIntervalMs),
    );

    _gpsSub = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen(_onPosition, onError: (_) {});
  }

  void _onPosition(Position pos) {
    if (!state.isRunning || state.isPaused) return;

    final newPath = List<LatLng>.from(state.pathCoordinates)
      ..add(LatLng(pos.latitude, pos.longitude));

    double addedKm = 0.0;
    if (_lastPosition != null) {
      final meters = haversineDistance(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );
      addedKm = meters / 1000.0;
    }
    _lastPosition = pos;

    final newDistanceKm = state.distanceKm + addedKm;
    final newXP = calcXP(
      durationSeconds: state.elapsedSeconds,
      distanceKm:      newDistanceKm,
    );

    state = state.copyWith(
      distanceKm:      newDistanceKm,
      pathCoordinates: newPath,
      xp:              newXP,
    );
  }

  // ── Pedometer ─────────────────────────────────────────────────────────────

  void _startPedometer() {
    _pedometerSub = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: (_) {},
    );
  }

  void _onStepCount(StepCount event) {
    if (!state.isRunning || state.isPaused) return;

    // First event after startRun — capture boot-cumulative offset
    if (_stepOffset == 0 && event.steps > 0) {
      _stepOffset = event.steps;
    }
    final sessionSteps = event.steps - _stepOffset;
    if (sessionSteps < 0) return;

    state = state.copyWith(steps: sessionSteps);
  }

  // ── Cleanup ────────────────────────────────────────────────────────────────

  void _cancelAll() {
    _timer?.cancel();
    _gpsSub?.cancel();
    _pedometerSub?.cancel();
    _timer        = null;
    _gpsSub       = null;
    _pedometerSub = null;
  }

  @override
  void dispose() {
    _cancelAll();
    super.dispose();
  }
}

final runProvider = StateNotifierProvider<RunNotifier, RunState>(
  (ref) => RunNotifier(),
);
