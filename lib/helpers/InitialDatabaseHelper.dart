import 'package:postgres/postgres.dart';

class InitialDatabaseHelper {
  PostgreSQLConnection? _connection;

  // PostgreSQL 연결 설정
  bool get isConnected => _connection != null && !_connection!.isClosed;

  Future<void> connect() async {
    if (_connection == null || _connection!.isClosed) {
      _connection = PostgreSQLConnection(
        '172.30.1.100',
        5432,
        'traveltree',
        username: 'postgres',
        password: 'juyong03015!',
      );

      await _connection!.open();
      print('PostgreSQL 연결 성공');
    }
  }

  // 여행 데이터 추가
  Future<int> insertTrip({
    required String name,
    required String country,
    required DateTime startDate,
    required DateTime endDate,
    required int userId, // user_id 추가
  }) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    final result = await _connection!.query(
      '''
      INSERT INTO travel (name, country, start_date, end_date, user_id)
      VALUES (@name, @country, @start_date, @end_date, @user_id)
      RETURNING id
      ''',
      substitutionValues: {
        'name': name,
        'country': country,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'user_id': userId, // user_id 값 추가
      },
    );

    return result.first[0] as int; // 반환된 여행 ID
  }

  // 여행 데이터 불러오기
  Future<List<Map<String, dynamic>>> getTrips(int userId) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    final result = await _connection!.query(
      '''
      SELECT id, name, country, start_date, end_date
      FROM travel
      WHERE user_id = @user_id
      ORDER BY start_date ASC
      ''',
      substitutionValues: {
        'user_id': userId, // user_id 조건 추가
      },
    );

    return result.map((row) {
      return {
        'id': row[0],
        'name': row[1],
        'country': row[2],
        'start_date': row[3].toString(),
        'end_date': row[4].toString(),
      };
    }).toList();
  }

  // 여행 데이터 삭제
  Future<void> deleteTrip(int id) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    await _connection!.query(
      '''
      DELETE FROM travel WHERE id = @id
      ''',
      substitutionValues: {
        'id': id,
      },
    );
  }
}
