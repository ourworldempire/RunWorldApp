import 'package:dio/dio.dart';
import 'package:runworld/services/api_service.dart';

class TerritoryZone {
  final String id;
  final String name;
  final String ownerColor;
  final String? ownerId;
  final bool   isOwn;
  final double centerLat;
  final double centerLng;
  final List<Map<String, double>> coordinates;

  const TerritoryZone({
    required this.id,
    required this.name,
    required this.ownerColor,
    this.ownerId,
    required this.isOwn,
    required this.centerLat,
    required this.centerLng,
    this.coordinates = const [],
  });

  // Backend: { id, name, ownerColor, coordinates, owner_id, isOwn }
  factory TerritoryZone.fromJson(Map<String, dynamic> json, String? currentUserId) {
    final rawCoords = (json['coordinates'] as List<dynamic>? ?? []);
    final coords = rawCoords.map((c) {
      final m = c as Map<String, dynamic>;
      return <String, double>{
        'lat': (m['latitude']  ?? m['lat']  as num).toDouble(),
        'lng': (m['longitude'] ?? m['lng']  as num).toDouble(),
      };
    }).toList();

    final ownerId = json['owner_id'] as String?;
    return TerritoryZone(
      id:          json['id']         as String,
      name:        json['name']       as String,
      ownerColor:  json['ownerColor'] as String? ?? '#3498DB',
      ownerId:     ownerId,
      isOwn:       currentUserId != null && ownerId == currentUserId,
      centerLat:   (json['center_lat'] as num? ?? 12.9716).toDouble(),
      centerLng:   (json['center_lng'] as num? ?? 77.5946).toDouble(),
      coordinates: coords,
    );
  }

  static List<TerritoryZone> get mockZones => const [
    TerritoryZone(id: 'z1', name: 'MG Road',     ownerColor: '#E94560', isOwn: true,  centerLat: 12.9758, centerLng: 77.6096),
    TerritoryZone(id: 'z2', name: 'Indiranagar', ownerColor: '#E94560', isOwn: true,  centerLat: 12.9784, centerLng: 77.6408),
    TerritoryZone(id: 'z3', name: 'Koramangala', ownerColor: '#3498DB', isOwn: false, centerLat: 12.9352, centerLng: 77.6245),
  ];
}

class MapService {
  MapService._();
  static final MapService instance = MapService._();
  final Dio _dio = ApiService.instance.dio;

  // Backend query params: minLat, maxLat, minLng, maxLng
  Future<List<TerritoryZone>> getTerritories({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    String? currentUserId,
  }) async {
    try {
      final resp = await _dio.get('/map/territories', queryParameters: {
        'minLat': swLat,
        'maxLat': neLat,
        'minLng': swLng,
        'maxLng': neLng,
      });
      final list = resp.data['territories'] as List<dynamic>;
      return list
          .map((z) => TerritoryZone.fromJson(z as Map<String, dynamic>, currentUserId))
          .toList();
    } catch (_) {
      return TerritoryZone.mockZones;
    }
  }

  // Backend: POST /map/territories/capture  body: { zone_id }
  Future<TerritoryZone?> captureTerritory(String zoneId, {String? currentUserId}) async {
    try {
      final resp = await _dio.post('/map/territories/capture', data: {'zone_id': zoneId});
      return TerritoryZone.fromJson(
          resp.data['territory'] as Map<String, dynamic>, currentUserId);
    } catch (_) {
      return null;
    }
  }

  Future<List<TerritoryZone>> getUserTerritories(String userId) async {
    try {
      final resp = await _dio.get('/map/territories/user/$userId');
      final list = resp.data['territories'] as List<dynamic>;
      return list
          .map((z) => TerritoryZone.fromJson(z as Map<String, dynamic>, userId))
          .toList();
    } catch (_) {
      return TerritoryZone.mockZones.where((z) => z.isOwn).toList();
    }
  }
}
