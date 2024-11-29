import 'package:postgres/postgres.dart';

class PathpointDatabaseHelper {
  PostgreSQLConnection? _connection;

  // PostgreSQL 데이터베이스 연결
  Future<void> connect() async {
    _connection = PostgreSQLConnection(
      '172.30.1.100', // PostgreSQL 서버 주소
      5432, // PostgreSQL 기본 포트
      'traveltree', // 데이터베이스 이름
      username: 'postgres', // 사용자 이름
      password: 'juyong03015!', // 비밀번호
    );

    await _connection!.open();
    print('PostgreSQL 데이터베이스 연결 성공');
  }

  // 경로 데이터를 삽입
  Future<void> insertPathPoint({
    required int travelId,
    required double latitude,
    required double longitude,
  }) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    await _connection!.query(
      '''
      INSERT INTO path_points (travel_id, latitude, longitude)
      VALUES (@travelId, @latitude, @longitude)
      ''',
      substitutionValues: {
        'travelId': travelId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  // 특정 여행 ID에 해당하는 경로 데이터를 가져오기
  Future<List<Map<String, dynamic>>> getPathPoints(int travelId) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    final result = await _connection!.query(
      '''
      SELECT latitude, longitude
      FROM path_points
      WHERE travel_id = @travelId
      ORDER BY id ASC
      ''',
      substitutionValues: {'travelId': travelId},
    );

    return result.map((row) {
      return {
        'latitude': row[0] as double,
        'longitude': row[1] as double,
      };
    }).toList();
  }

  // PostgreSQL 연결 종료
  Future<void> close() async {
    if (_connection != null && !_connection!.isClosed) {
      await _connection!.close();
      print('PostgreSQL 연결 종료');
    }
  }
}
