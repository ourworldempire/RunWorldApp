import 'package:flutter/material.dart';

class ChallengeModel {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final String type; // distance | territory | streak | speed | leaderboard | social
  final double goalValue;
  final String goalUnit;
  final DateTime startDate;
  final DateTime endDate;
  final int rewardXp;
  final int participantCount;
  final bool joined;
  final double userProgress;
  final bool userCompleted;
  final String status; // active | upcoming | completed

  const ChallengeModel({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.type,
    required this.goalValue,
    required this.goalUnit,
    required this.startDate,
    required this.endDate,
    required this.rewardXp,
    required this.participantCount,
    required this.joined,
    required this.userProgress,
    required this.userCompleted,
    required this.status,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> j) => ChallengeModel(
        id:             j['id'] as String,
        emoji:          j['emoji'] as String? ?? '🏃',
        title:          j['title'] as String,
        description:    j['description'] as String? ?? '',
        type:           j['type'] as String? ?? 'distance',
        goalValue:      (j['goal_value'] as num?)?.toDouble() ?? 1,
        goalUnit:       j['goal_unit'] as String? ?? 'km',
        startDate:      DateTime.parse(j['start_date'] as String),
        endDate:        DateTime.parse(j['end_date'] as String),
        rewardXp:       j['reward_xp'] as int? ?? 0,
        participantCount: j['participant_count'] as int? ?? 0,
        joined:         j['joined'] as bool? ?? false,
        userProgress:   (j['user_progress'] as num?)?.toDouble() ?? 0,
        userCompleted:  j['user_completed'] as bool? ?? false,
        status:         j['status'] as String? ?? 'active',
      );

  String get deadlineLabel {
    if (status == 'completed') return 'Completed';
    final now = DateTime.now();
    if (status == 'upcoming') {
      final d = startDate.difference(now).inDays;
      return d == 0 ? 'Starts today' : 'Starts in $d days';
    }
    final d = endDate.difference(now).inDays;
    if (d == 0) return 'Ends today';
    return '$d days left';
  }

  double get progressRatio =>
      goalValue > 0 ? (userProgress / goalValue).clamp(0.0, 1.0) : 0.0;

  Color get color {
    switch (type) {
      case 'territory':   return const Color(0xFF27C93F);
      case 'streak':      return const Color(0xFFF5A623);
      case 'speed':
      case 'social':      return const Color(0xFF3498DB);
      case 'leaderboard': return const Color(0xFFFFD700);
      default:            return const Color(0xFFE94560); // distance
    }
  }
}
