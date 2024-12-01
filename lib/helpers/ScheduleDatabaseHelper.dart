import 'package:postgres/postgres.dart';

class ScheduleDatabaseHelper {
  late PostgreSQLConnection _connection;

  /// PostgreSQL 연결
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

  /// 일정 삽입
  Future<int> insertSchedule({
    required String title,
    required String content,
    required bool completed,
    required DateTime date,
    required int travelId,
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
        'travel_id': travelId,
      },
    );

    return result.first[0] as int; // 삽입된 데이터의 ID 반환
  }

  /// 특정 ID를 기준으로 일정 업데이트
  Future<void> updateSchedule({
    required int id,
    required String title,
    required String content,
    required bool completed,
    required DateTime date,
    required int travelId,
  }) async {
    await _connection.query(
      '''
      UPDATE schedules
      SET title = @title,
          content = @content,
          completed = @completed,
          date = @date,
          travel_id = @travel_id
      WHERE id = @id
      ''',
      substitutionValues: {
        'id': id,
        'title': title,
        'content': content,
        'completed': completed,
        'date': date.toIso8601String(),
        'travel_id': travelId,
      },
    );

    print('Schedule with ID $id updated');
  }

  /// 특정 날짜 및 여행 ID로 일정 가져오기
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
        'travel_id': travelId,
      },
    );

    return results.map((row) => row['schedules']!).toList();
  }

  /// 특정 ID를 기준으로 일정 삭제
  Future<void> deleteSchedule(int id) async {
    await _connection.query(
      '''
      DELETE FROM schedules WHERE id = @id
      ''',
      substitutionValues: {'id': id},
    );

    print('Schedule with ID $id deleted');
  }

  /// PostgreSQL 연결 종료
  Future<void> close() async {
    await _connection.close();
    print('PostgreSQL 연결 종료');
  }
}
