import 'package:postgres/postgres.dart';

class ScheduleDatabaseHelper {
  late PostgreSQLConnection _connection;

  /// Connect to the PostgreSQL database.
  Future<void> connect() async {
    _connection = PostgreSQLConnection(
      '172.30.1.100', // PostgreSQL 서버 주소
      5432, // 기본 PostgreSQL 포트
      'traveltree', // 데이터베이스 이름
      username: 'postgres', // PostgreSQL 사용자 이름
      password: 'juyong03015!', // PostgreSQL 비밀번호
    );

    await _connection.open();
    print('PostgreSQL 연결 성공');
  }

  /// Insert a schedule into the database.
  Future<int> insertSchedule({
    required String title,
    required String content,
    required bool completed,
    required DateTime date,
    required int travelId, // travelId 추가
  }) async {
    final result = await _connection.query(
      '''
      INSERT INTO schedules (title, content, completed, date, travel_id)
      VALUES (@title, @content, @completed, @date, @travel_id)
      RETURNING id
      ''',
      substitutionValues: {
        'title': title,
        'content': content,
        'completed': completed,
        'date': date.toIso8601String(),
        'travel_id': travelId, // travelId 값 전달
      },
    );

    return result.first[0] as int;
  }

  /// Get schedules from the database for a specific date and travelId.
  Future<List<Map<String, dynamic>>> getSchedulesByDateAndTravelId(
      DateTime date, int travelId) async {
    final results = await _connection.mappedResultsQuery(
      '''
      SELECT id, title, content, completed, date
      FROM schedules
      WHERE date = @date AND travel_id = @travel_id
      ORDER BY id
      ''',
      substitutionValues: {
        'date': date.toIso8601String(),
        'travel_id': travelId, // travelId 조건 추가
      },
    );

    return results.map((row) => row['schedules']!).toList();
  }

  /// Delete a schedule from the database.
  Future<void> deleteSchedule(int id) async {
    await _connection.query(
      '''
      DELETE FROM schedules WHERE id = @id
      ''',
      substitutionValues: {'id': id},
    );
    print('Schedule with ID $id deleted');
  }

  /// Close the database connection.
  Future<void> close() async {
    await _connection.close();
    print('PostgreSQL 연결 종료');
  }
}
