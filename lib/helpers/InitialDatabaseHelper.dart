import 'package:postgres/postgres.dart';

class InitialDatabaseHelper {
  PostgreSQLConnection? _connection;

  // PostgreSQL 연결 상태 확인
  bool get isConnected => _connection != null && !_connection!.isClosed;

  // PostgreSQL 연결
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

  // PostgreSQL 연결 해제
  Future<void> close() async {
    if (_connection != null && !_connection!.isClosed) {
      await _connection!.close();
      print('PostgreSQL 연결 종료');
    }
  }

  // 여행 데이터 추가
  Future<int> insertTrip({
    required String name,
    required String country,
    required DateTime startDate,
    required DateTime endDate,
    required int userId,
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
        'user_id': userId,
      },
    );

    return result.first[0] as int;
  }

  // 특정 사용자의 여행 데이터 가져오기
  Future<List<Map<String, dynamic>>> getTrips(int userId) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    final result = await _connection!.query(
      '''
      SELECT id, name, country, start_date, end_date, is_finalized
      FROM travel
      WHERE user_id = @user_id
      ORDER BY start_date ASC
      ''',
      substitutionValues: {
        'user_id': userId,
      },
    );

    return result.map((row) {
      return {
        'id': row[0],
        'name': row[1],
        'country': row[2],
        'start_date': row[3].toString(),
        'end_date': row[4].toString(),
        'is_finalized': row[5] as bool,
      };
    }).toList();
  }

  // 최종 저장된 여행 데이터 가져오기
  Future<List<Map<String, dynamic>>> getFinalizedTravels(int userId) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    final result = await _connection!.query(
      '''
      SELECT id, name, country, start_date, end_date
      FROM travel
      WHERE user_id = @user_id AND is_finalized = TRUE
      ORDER BY start_date DESC
      ''',
      substitutionValues: {
        'user_id': userId,
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

  // 여행 잠금 (최종 저장) 처리
  Future<void> lockTravel(int travelId) async {
    if (_connection == null || _connection!.isClosed) {
      await connect(); // 연결이 닫혀 있으면 다시 연결
    }

    await _connection!.query(
      '''
      UPDATE travel
      SET is_finalized = TRUE
      WHERE id = @id
      ''',
      substitutionValues: {
        'id': travelId,
      },
    );
  }

  // SNS 업로드 상태 설정
  Future<void> markAsUploadedToSNS(int travelId) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    await _connection!.query(
      '''
      UPDATE travel
      SET is_uploaded_to_sns = TRUE
      WHERE id = @id
      ''',
      substitutionValues: {
        'id': travelId,
      },
    );
  }
}
