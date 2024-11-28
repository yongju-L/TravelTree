import 'package:postgres/postgres.dart';

class ExpenseDatabaseHelper {
  PostgreSQLConnection? _connection;

  // PostgreSQL 연결 설정
  Future<void> connect() async {
    _connection = PostgreSQLConnection(
      '172.30.1.100', // PostgreSQL 서버 주소
      5432, // PostgreSQL 기본 포트
      'traveltree', // 데이터베이스 이름
      username: 'postgres', // 사용자 이름
      password: 'juyong03015!', // 비밀번호
    );

    await _connection!.open();
    print('PostgreSQL 연결 성공');
  }

  // 경비 추가
  Future<int> insertExpense({
    required String category,
    required double amount,
    required DateTime time,
    required bool isBudgetAddition,
    required DateTime date,
    required int travelId, // travelId 추가
  }) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    final result = await _connection!.query(
      '''
      INSERT INTO expenses (category, amount, time, is_budget_addition, date, travel_id)
      VALUES (@category, @amount, @time, @is_budget_addition, @date, @travel_id)
      RETURNING id
      ''',
      substitutionValues: {
        'category': category,
        'amount': amount,
        'time': time.toIso8601String(),
        'is_budget_addition': isBudgetAddition,
        'date': date.toIso8601String(),
        'travel_id': travelId, // travelId 추가
      },
    );

    return result.first[0] as int; // 반환된 경비 ID
  }

  // 특정 날짜 및 여행 ID에 해당하는 경비 가져오기
  Future<List<Map<String, dynamic>>> getExpensesByDateAndTravelId(
      DateTime date, int travelId) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    final result = await _connection!.query(
      '''
      SELECT id, category, amount, time, is_budget_addition, date, travel_id
      FROM expenses
      WHERE date = @date AND travel_id = @travel_id
      ORDER BY time DESC
      ''',
      substitutionValues: {
        'date': date.toIso8601String(),
        'travel_id': travelId, // travelId 조건 추가
      },
    );

    return result.map((row) {
      return {
        'id': row[0],
        'category': row[1],
        'amount': row[2],
        'time': row[3].toString(),
        'is_budget_addition': row[4],
        'date': row[5].toString(),
        'travel_id': row[6],
      };
    }).toList();
  }

  // 특정 ID의 경비 삭제
  Future<void> deleteExpense(int id) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    await _connection!.query(
      '''
      DELETE FROM expenses WHERE id = @id
      ''',
      substitutionValues: {
        'id': id,
      },
    );
  }

  // 특정 카테고리, 날짜 및 여행 ID에 해당하는 경비 삭제
  Future<void> deleteByCategoryAndDateAndTravelId(
      String category, DateTime date, int travelId) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    await _connection!.query(
      '''
      DELETE FROM expenses 
      WHERE category = @category AND date = @date AND travel_id = @travel_id
      ''',
      substitutionValues: {
        'category': category,
        'date': date.toIso8601String(),
        'travel_id': travelId, // travelId 조건 추가
      },
    );
  }

  // 특정 여행 ID 및 날짜에 대해 총 경비 업데이트
  Future<void> updateTotalBudget(
      double totalBudget, DateTime date, int travelId) async {
    if (_connection == null || _connection!.isClosed) {
      throw Exception('Database connection is not initialized.');
    }

    await _connection!.query(
      '''
      UPDATE expenses
      SET amount = @totalBudget
      WHERE category = '총 경비' AND date = @date AND travel_id = @travel_id
      ''',
      substitutionValues: {
        'totalBudget': totalBudget,
        'date': date.toIso8601String(),
        'travel_id': travelId, // travelId 조건 추가
      },
    );
  }
}
