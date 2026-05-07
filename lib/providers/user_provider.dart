import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:runworld/models/user_model.dart';
import 'package:runworld/utils/constants.dart';
import 'package:runworld/utils/fitness_calc.dart';

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null);

  void setUser(UserModel user) {
    state = user;
    _persist(user);
  }

  void clearUser() {
    state = null;
    _clear();
  }

  // Optimistically add XP + handle leveling locally (backend is source of truth on next save)
  void addXP(int amount) {
    final u = state;
    if (u == null) return;
    final result = applyXP(
      currentLevel:    u.level,
      currentXP:       u.xp,
      currentXpToNext: u.xpToNext,
      xpEarned:        amount,
    );
    state = u.copyWith(
      level:    result['level'],
      xp:       result['xp'],
      xpToNext: result['xpToNext'],
    );
    _persist(state!);
  }

  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kPrefUser);
    if (raw != null) {
      try {
        state = UserModel.fromJsonString(raw);
      } catch (_) {
        await prefs.remove(kPrefUser);
      }
    }
  }

  Future<void> _persist(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPrefUser, user.toJsonString());
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kPrefUser);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>(
  (ref) => UserNotifier(),
);
