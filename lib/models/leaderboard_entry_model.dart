class LeaderboardEntryModel {
  final String id;
  final int rank;
  final String name;
  final String avatar;
  final int level;
  final int xp;
  final double distanceKm;
  final double territoryPercent;
  final bool isYou;

  const LeaderboardEntryModel({
    required this.id,
    required this.rank,
    required this.name,
    required this.avatar,
    required this.level,
    required this.xp,
    required this.distanceKm,
    required this.territoryPercent,
    this.isYou = false,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntryModel(
        id:               json['id'] as String,
        rank:             (json['rank'] as num).toInt(),
        name:             json['name'] as String,
        avatar:           json['avatar'] as String? ?? '🏃',
        level:            (json['level'] as num?)?.toInt() ?? 1,
        xp:               (json['xp'] as num?)?.toInt() ?? 0,
        distanceKm:       (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
        territoryPercent: (json['territoryPercent'] as num?)?.toDouble() ?? 0.0,
        isYou:            json['isYou'] as bool? ?? false,
      );

  static List<LeaderboardEntryModel> get mockList => [
    const LeaderboardEntryModel(id: '1', rank: 1, name: 'Arjun', avatar: '⚡', level: 8, xp: 9200, distanceKm: 88, territoryPercent: 66.6),
    const LeaderboardEntryModel(id: '2', rank: 2, name: 'Priya', avatar: '🦅', level: 6, xp: 7100, distanceKm: 64, territoryPercent: 50.0),
    const LeaderboardEntryModel(id: '3', rank: 3, name: 'Runner', avatar: '🏃', level: 3, xp: 4800, distanceKm: 42, territoryPercent: 33.3, isYou: true),
  ];
}
