import 'package:latlong2/latlong.dart';

class TerritoryModel {
  final String id;
  final String name;
  final String ownerColor;
  final List<LatLng> coordinates;
  final String? ownerId;
  final bool isOwn;
  final DateTime? capturedAt;

  const TerritoryModel({
    required this.id,
    required this.name,
    required this.ownerColor,
    required this.coordinates,
    this.ownerId,
    this.isOwn = false,
    this.capturedAt,
  });

  factory TerritoryModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final rawCoords = json['coordinates'] as List<dynamic>? ?? [];
    final coords = rawCoords.map((c) {
      final m = c as Map<String, dynamic>;
      return LatLng(
        (m['latitude'] as num).toDouble(),
        (m['longitude'] as num).toDouble(),
      );
    }).toList();

    final ownerId = json['owner_id'] as String?;

    return TerritoryModel(
      id:          json['id'] as String,
      name:        json['name'] as String,
      ownerColor:  json['ownerColor'] as String? ?? '#3498DB',
      coordinates: coords,
      ownerId:     ownerId,
      isOwn:       currentUserId != null && ownerId == currentUserId,
      capturedAt:  json['captured_at'] != null
          ? DateTime.parse(json['captured_at'] as String)
          : null,
    );
  }

  TerritoryModel copyWith({bool? isOwn, String? ownerColor, String? ownerId}) =>
      TerritoryModel(
        id:          id,
        name:        name,
        ownerColor:  ownerColor ?? this.ownerColor,
        coordinates: coordinates,
        ownerId:     ownerId ?? this.ownerId,
        isOwn:       isOwn ?? this.isOwn,
        capturedAt:  capturedAt,
      );
}

class TerritoryStats {
  final int owned;
  final int total;
  final double percent;

  const TerritoryStats({required this.owned, required this.total, required this.percent});

  factory TerritoryStats.fromJson(Map<String, dynamic> json) => TerritoryStats(
    owned:   (json['owned'] as num).toInt(),
    total:   (json['total'] as num).toInt(),
    percent: (json['percent'] as num).toDouble(),
  );
}
