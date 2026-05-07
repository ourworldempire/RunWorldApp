import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:runworld/utils/constants.dart';

class SettingsState {
  final String units;
  final int dailyStepGoal;
  final double weightKg;
  final bool notificationsEnabled;
  final bool privacyPublic;

  const SettingsState({
    this.units = 'km',
    this.dailyStepGoal = 8000,
    this.weightKg = 70.0,
    this.notificationsEnabled = true,
    this.privacyPublic = true,
  });

  SettingsState copyWith({
    String? units,
    int? dailyStepGoal,
    double? weightKg,
    bool? notificationsEnabled,
    bool? privacyPublic,
  }) => SettingsState(
    units:                 units                 ?? this.units,
    dailyStepGoal:         dailyStepGoal         ?? this.dailyStepGoal,
    weightKg:              weightKg              ?? this.weightKg,
    notificationsEnabled:  notificationsEnabled  ?? this.notificationsEnabled,
    privacyPublic:         privacyPublic         ?? this.privacyPublic,
  );

  Map<String, dynamic> toJson() => {
    'units':                units,
    'dailyStepGoal':        dailyStepGoal,
    'weightKg':             weightKg,
    'notificationsEnabled': notificationsEnabled,
    'privacyPublic':        privacyPublic,
  };

  factory SettingsState.fromJson(Map<String, dynamic> json) => SettingsState(
    units:                json['units'] as String? ?? 'km',
    dailyStepGoal:        (json['dailyStepGoal'] as num?)?.toInt() ?? 8000,
    weightKg:             (json['weightKg'] as num?)?.toDouble() ?? 70.0,
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    privacyPublic:        json['privacyPublic'] as bool? ?? true,
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void setUnits(String units) {
    state = state.copyWith(units: units);
    _persist();
  }

  void setDailyStepGoal(int goal) {
    state = state.copyWith(dailyStepGoal: goal);
    _persist();
  }

  void setWeightKg(double kg) {
    state = state.copyWith(weightKg: kg);
    _persist();
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    _persist();
  }

  void togglePrivacy() {
    state = state.copyWith(privacyPublic: !state.privacyPublic);
    _persist();
  }

  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kPrefSettings);
    if (raw != null) {
      try {
        state = SettingsState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        await prefs.remove(kPrefSettings);
      }
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPrefSettings, jsonEncode(state.toJson()));
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
