import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:postgres/postgres.dart';

class PathpointDatabaseHelper {
  final PostgreSQLConnection connection;

  PathpointDatabaseHelper()
      : connection = PostgreSQLConnection(
          '172.30.1.100', // PostgreSQL 호스트
          5432, // 포트
          'traveltree', // 데이터베이스 이름
          username: 'postgres',
          password: 'juyong03015!',
        );

  Future<void> connect() async {
    if (connection.isClosed) {
      await connection.open();
    }
  }

  /// travel_routes 테이블의 데이터를 업데이트 또는 삽입
  Future<void> upsertPolyline(int travelId, List<LatLng> polylinePoints) async {
    try {
      // LatLng 리스트를 WKT LINESTRING 형식으로 변환
      final lineString = polylinePoints
          .map((point) => '${point.longitude} ${point.latitude}')
          .join(', ');

      const query = '''
        INSERT INTO travel_routes (travel_id, route)
        VALUES (@travelId, ST_GeomFromText(@lineString, 4326))
        ON CONFLICT (travel_id)
        DO UPDATE SET route = EXCLUDED.route
      ''';

      await connection.query(query, substitutionValues: {
        'travelId': travelId,
        'lineString': 'LINESTRING($lineString)',
      });

      print('Polyline upserted successfully.');
    } catch (e) {
      print('Error upserting polyline: $e');
    }
  }

  /// travel_routes 테이블에서 특정 travel_id의 Polyline 데이터를 가져오기
  Future<List<LatLng>> getPolyline(int travelId) async {
    try {
      const query = '''
        SELECT ST_AsText(route) AS route
        FROM travel_routes
        WHERE travel_id = @travelId
      ''';

      final results = await connection.query(query, substitutionValues: {
        'travelId': travelId,
      });

      if (results.isNotEmpty) {
        final wkt = results.first[0] as String;
        return _parseLineString(wkt);
      }
    } catch (e) {
      print('Error fetching polyline: $e');
    }
    return [];
  }

  List<LatLng> _parseLineString(String wkt) {
    // WKT "LINESTRING(lon1 lat1, lon2 lat2, ...)"을 LatLng 리스트로 변환
    final coordinates = wkt.replaceAll('LINESTRING(', '').replaceAll(')', '');
    return coordinates.split(',').map((coord) {
      final parts = coord.trim().split(' ');
      final lon = double.parse(parts[0]);
      final lat = double.parse(parts[1]);
      return LatLng(lat, lon);
    }).toList();
  }

  Future<void> close() async {
    await connection.close();
  }
}
