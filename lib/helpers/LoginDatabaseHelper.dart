import 'package:postgres/postgres.dart';

class LoginDatabaseHelper {
  late PostgreSQLConnection _connection;

  // PostgreSQL 연결 설정
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

  // 사용자 등록
  Future<int> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final result = await _connection.query(
      '''
      INSERT INTO users (username, email, password)
      VALUES (@username, @email, @password)
      RETURNING id
      ''',
      substitutionValues: {
        'username': username,
        'email': email,
        'password': password,
      },
    );

    return result.first[0] as int; // 반환된 사용자 ID
  }

  // 사용자 인증
  Future<Map<String, dynamic>?> authenticateUser({
    required String email,
    required String password,
  }) async {
    final result = await _connection.query(
      '''
    SELECT id, username, email
    FROM users
    WHERE TRIM(LOWER(email)) = TRIM(LOWER(@email)) AND password = @password
    ''',
      substitutionValues: {
        'email': email,
        'password': password,
      },
    );

    if (result.isNotEmpty) {
      return {
        'id': result.first[0],
        'username': result.first[1],
        'email': result.first[2],
      };
    }
    print(result);
    return null; // 인증 실패
  }
}
