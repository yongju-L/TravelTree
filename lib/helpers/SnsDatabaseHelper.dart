import 'package:postgres/postgres.dart';

class SnsDatabaseHelper {
  PostgreSQLConnection? _connection;

  /// PostgreSQL 연결
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

  /// PostgreSQL 연결 해제
  Future<void> close() async {
    if (_connection != null && !_connection!.isClosed) {
      await _connection!.close();
      print('PostgreSQL 연결 종료');
    }
  }

  /// 여행 SNS에 업로드
  Future<void> uploadTravelToSns({
    required int travelId,
    required String travelName,
    required String travelCountry,
    required String startDate,
    required String endDate,
    required String username,
    required int userId, // user_id 추가
  }) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    await _connection!.query(
      '''
    INSERT INTO sns_info (travel_id, travel_name, travel_country, start_date, end_date, username, user_id)
    VALUES (@travelId, @travelName, @travelCountry, @startDate, @endDate, @username, @userId)
    ''',
      substitutionValues: {
        'travelId': travelId,
        'travelName': travelName,
        'travelCountry': travelCountry,
        'startDate': startDate,
        'endDate': endDate,
        'username': username,
        'userId': userId, // 추가된 값
      },
    );

    print('Travel uploaded to SNS: $travelName');
  }

  /// 좋아요 수 증가
  Future<void> likeTravel(int snsId, int userId) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    // 좋아요 상태 확인
    final checkLikeResult = await _connection!.query(
      '''
      SELECT id FROM likes WHERE sns_id = @snsId AND user_id = @userId
      ''',
      substitutionValues: {'snsId': snsId, 'userId': userId},
    );

    if (checkLikeResult.isEmpty) {
      // 좋아요 추가
      await _connection!.query(
        '''
        INSERT INTO likes (sns_id, user_id) VALUES (@snsId, @userId)
        ''',
        substitutionValues: {'snsId': snsId, 'userId': userId},
      );

      // sns_info의 좋아요 수 증가
      await _connection!.query(
        '''
        UPDATE sns_info SET total_likes = total_likes + 1 WHERE id = @snsId
        ''',
        substitutionValues: {'snsId': snsId},
      );
    }
  }

  Future<void> unlikeTravel(int snsId, int userId) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    // 좋아요 상태 확인
    final checkLikeResult = await _connection!.query(
      '''
      SELECT id FROM likes WHERE sns_id = @snsId AND user_id = @userId
      ''',
      substitutionValues: {'snsId': snsId, 'userId': userId},
    );

    if (checkLikeResult.isNotEmpty) {
      // 좋아요 제거
      await _connection!.query(
        '''
        DELETE FROM likes WHERE sns_id = @snsId AND user_id = @userId
        ''',
        substitutionValues: {'snsId': snsId, 'userId': userId},
      );

      // sns_info의 좋아요 수 감소
      await _connection!.query(
        '''
        UPDATE sns_info SET total_likes = total_likes - 1 WHERE id = @snsId
        ''',
        substitutionValues: {'snsId': snsId},
      );
    }
  }

  /// SNS 데이터 가져오기 (좋아요 포함)
  Future<List<Map<String, dynamic>>> getAllUploadedTravels(int userId) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    final result = await _connection!.query(
      '''
      SELECT
        sns_info.id AS sns_id,
        sns_info.travel_id,
        sns_info.travel_name,
        sns_info.travel_country,
        sns_info.start_date,
        sns_info.end_date,
        sns_info.username,
        sns_info.total_likes,
        sns_info.user_id, -- user_id 추가
        EXISTS (
          SELECT 1 FROM likes WHERE sns_id = sns_info.id AND user_id = @userId
        ) AS liked_by_user
      FROM sns_info
      ORDER BY sns_info.id DESC
      ''',
      substitutionValues: {'userId': userId},
    );

    return result.map((row) {
      return {
        'sns_id': row[0],
        'travel_id': row[1],
        'travel_name': row[2],
        'travel_country': row[3],
        'start_date': row[4]?.toString(),
        'end_date': row[5]?.toString(),
        'username': row[6],
        'total_likes': row[7] ?? 0,
        'user_id': row[8], // user_id 추가
        'liked_by_user': row[9] as bool,
      };
    }).toList();
  }
}
