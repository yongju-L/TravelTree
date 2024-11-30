import 'package:postgres/postgres.dart';

class TransportationDatabaseHelper {
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

  // transportation 데이터 삽입 또는 업데이트
  Future<void> upsertTransportationData({
    required int travelId,
    required String mode,
    required double distance,
    required int duration,
  }) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    // INSERT 또는 UPDATE 쿼리 실행
    const query = '''
      INSERT INTO transportation (travel_id, mode, distance, duration, timestamp)
      VALUES (@travelId, @mode, @distance, @duration, NOW())
      ON CONFLICT (travel_id, mode)
      DO UPDATE SET
        distance = EXCLUDED.distance,
        duration = EXCLUDED.duration,
        timestamp = NOW();
    ''';

    await _connection!.query(query, substitutionValues: {
      'travelId': travelId,
      'mode': mode,
      'distance': distance,
      'duration': duration,
    });

    print('Transportation data upserted successfully.');
  }

  // 특정 여행 ID와 모드별로 transportation 데이터 가져오기
  Future<List<Map<String, dynamic>>> getTransportationData(int travelId) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    final result = await _connection!.query(
      '''
    SELECT mode, distance::DOUBLE PRECISION, duration::INTEGER
    FROM transportation
    WHERE travel_id = @travelId
    ''',
      substitutionValues: {'travelId': travelId},
    );

    return result.map((row) {
      return {
        'mode': row[0],
        'distance': row[1] as double, // 명시적으로 double 처리
        'duration': row[2] as int, // 명시적으로 int 처리
      };
    }).toList();
  }

  Future<void> close() async {
    if (_connection != null && !_connection!.isClosed) {
      await _connection!.close();
      print('PostgreSQL 연결 종료');
    }
  }
}
