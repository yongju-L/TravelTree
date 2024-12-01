import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:postgres/postgres.dart';

class PathpointDatabaseHelper {
  PostgreSQLConnection? _connection;

  /// PostgreSQL 연결 설정
  Future<void> connect() async {
    // 기존 연결이 닫혀 있거나 없을 경우 새 연결 생성
    if (_connection == null || _connection!.isClosed) {
      _connection = PostgreSQLConnection(
        '172.30.1.100', // PostgreSQL 호스트
        5432, // 포트
        'traveltree', // 데이터베이스 이름
        username: 'postgres',
        password: 'juyong03015!',
      );
      try {
        await _connection!.open();
        print('PostgreSQL 연결 성공');
      } catch (e) {
        print('PostgreSQL 연결 실패: $e');
        rethrow;
      }
    } else {
      print('PostgreSQL 연결 이미 활성화됨');
    }
  }

  /// travel_routes 테이블의 데이터를 업데이트 또는 삽입
  Future<void> upsertPolyline(int travelId, List<LatLng> polylinePoints) async {
    try {
      final lineString = polylinePoints
          .map((point) => '${point.longitude} ${point.latitude}')
          .join(', ');

      const query = '''
        INSERT INTO travel_routes (travel_id, route)
        VALUES (@travelId, ST_GeomFromText(@lineString, 4326))
        ON CONFLICT (travel_id)
        DO UPDATE SET route = EXCLUDED.route
      ''';

      await _connection!.query(query, substitutionValues: {
        'travelId': travelId,
        'lineString': 'LINESTRING($lineString)',
      });

      print('Polyline 업로드 성공');
    } catch (e) {
      print('Polyline 업로드 실패: $e');
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

      final results = await _connection!.query(query, substitutionValues: {
        'travelId': travelId,
      });

      if (results.isNotEmpty) {
        final wkt = results.first[0] as String;
        return _parseLineString(wkt);
      }
    } catch (e) {
      print('Polyline 가져오기 실패: $e');
    }
    return [];
  }

  List<LatLng> _parseLineString(String wkt) {
    final coordinates = wkt.replaceAll('LINESTRING(', '').replaceAll(')', '');
    return coordinates.split(',').map((coord) {
      final parts = coord.trim().split(' ');
      final lon = double.parse(parts[0]);
      final lat = double.parse(parts[1]);
      return LatLng(lat, lon);
    }).toList();
  }

  /// map_pins 테이블에 핀 추가
  Future<int> addPin({
    required int travelId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final result = await _connection!.query(
        '''
        INSERT INTO map_pins (location, travel_id)
        VALUES (ST_SetSRID(ST_MakePoint(@lng, @lat), 4326), @travelId)
        RETURNING id
        ''',
        substitutionValues: {
          'lat': latitude,
          'lng': longitude,
          'travelId': travelId,
        },
      );

      return result.first[0] as int; // 반환된 ID
    } catch (e) {
      print('핀 추가 실패: $e');
      return -1; // 실패 시 -1 반환
    }
  }

  /// map_pins 테이블에서 특정 travel_id의 핀 가져오기
  Future<List<Map<String, dynamic>>> getPins(int travelId) async {
    try {
      final result = await _connection!.query(
        '''
        SELECT id, ST_X(location) AS longitude, ST_Y(location) AS latitude
        FROM map_pins
        WHERE travel_id = @travelId
        ''',
        substitutionValues: {'travelId': travelId},
      );

      return result.map((row) {
        return {
          'id': row[0],
          'longitude': row[1],
          'latitude': row[2],
        };
      }).toList();
    } catch (e) {
      print('핀 가져오기 실패: $e');
      return [];
    }
  }

  /// map_pins 테이블에서 핀 삭제
  Future<void> deletePin(int pinId) async {
    try {
      await _connection!.query(
        'DELETE FROM map_pins WHERE id = @pinId',
        substitutionValues: {'pinId': pinId},
      );
      print('핀 삭제 성공');
    } catch (e) {
      print('핀 삭제 실패: $e');
      throw Exception('핀 삭제 실패');
    }
  }

  /// photo 테이블에 사진 추가
  Future<void> addPhoto({
    required int pinId,
    required String photoPath,
  }) async {
    try {
      await _connection!.query(
        '''
        INSERT INTO photo (pin_id, photo_path)
        VALUES (@pinId, @photoPath)
        ''',
        substitutionValues: {
          'pinId': pinId,
          'photoPath': photoPath,
        },
      );

      print('사진 추가 성공');
    } catch (e) {
      print('사진 추가 실패: $e');
    }
  }

  /// photo 테이블에서 특정 핀에 연결된 사진 가져오기
  Future<List<Map<String, dynamic>>> getPhotos(int pinId) async {
    try {
      final result = await _connection!.query(
        '''
      SELECT id, photo_path
      FROM photo
      WHERE pin_id = @pinId
      ''',
        substitutionValues: {'pinId': pinId},
      );

      return result.map((row) {
        return {
          'id': row[0], // 사진 ID
          'photoPath': row[1], // 사진 경로
        };
      }).toList();
    } catch (e) {
      print('사진 가져오기 실패: $e');
      return [];
    }
  }

  /// photo 테이블에서 특정 사진 ID 삭제
  Future<void> deletePhoto(int photoId) async {
    try {
      await _connection!.query(
        '''
        DELETE FROM photo WHERE id = @photoId
        ''',
        substitutionValues: {'photoId': photoId},
      );
      print('사진 삭제 성공');
    } catch (e) {
      print('사진 삭제 실패: $e');
    }
  }

  /// PostgreSQL 연결 닫기
  Future<void> close() async {
    if (_connection != null && !_connection!.isClosed) {
      await _connection!.close();
      print('PostgreSQL 연결 닫기 성공');
    }
  }
}
