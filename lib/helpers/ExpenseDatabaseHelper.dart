import 'package:postgres/postgres.dart';

class DatabaseHelper {
  late PostgreSQLConnection _connection;

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

  Future<int> insertExpense({
    required String category,
    required double amount,
    required DateTime time,
    required bool isBudgetAddition,
    required DateTime date, // 날짜 추가
  }) async {
    final result = await _connection.query(
      '''
      INSERT INTO expenses (category, amount, time, is_budget_addition, date)
      VALUES (@category, @amount, @time, @is_budget_addition, @date)
      RETURNING id
      ''',
      substitutionValues: {
        'category': category,
        'amount': amount,
        'time': time.toUtc(),
        'is_budget_addition': isBudgetAddition,
        'date': DateTime(date.year, date.month, date.day).toUtc(), // 날짜만 저장
      },
    );

    return result.first[0] as int; // 새로 생성된 ID 반환
  }

  Future<List<Map<String, dynamic>>> getExpensesByDate(DateTime date) async {
    final results = await _connection.mappedResultsQuery(
      '''
      SELECT id, category, amount, time, is_budget_addition, date
      FROM expenses
      WHERE date = @date
      ORDER BY time DESC
      ''',
      substitutionValues: {
        'date': DateTime(date.year, date.month, date.day).toUtc(),
      },
    );

    return results.map((row) => row['expenses']!).toList();
  }

  Future<void> deleteExpense(int id) async {
    await _connection.query(
      'DELETE FROM expenses WHERE id = @id',
      substitutionValues: {'id': id},
    );
    print('Expense with ID $id deleted from the database');
  }

  Future<void> deleteByCategoryAndDate(String category, DateTime date) async {
    await _connection.query(
      '''
      DELETE FROM expenses
      WHERE category = @category AND date = @date
      ''',
      substitutionValues: {
        'category': category,
        'date': DateTime(date.year, date.month, date.day).toUtc(),
      },
    );
    print(
        'Expenses with category "$category" on date "$date" deleted from the database');
  }

  Future<void> updateTotalBudget(double newTotalBudget, DateTime date) async {
    await _connection.query(
      '''
      UPDATE expenses
      SET amount = @newTotalBudget
      WHERE category = '총 경비' AND date = @date
      ''',
      substitutionValues: {
        'newTotalBudget': newTotalBudget,
        'date': DateTime(date.year, date.month, date.day).toUtc(),
      },
    );
    print('총 경비 업데이트 완료: $newTotalBudget on $date');
  }

  Future<void> close() async {
    await _connection.close();
    print('PostgreSQL 연결 종료');
  }
}
