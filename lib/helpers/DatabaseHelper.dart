import 'package:postgres/postgres.dart';

class DatabaseHelper {
  late PostgreSQLConnection _connection;

  Future<void> connect() async {
    _connection = PostgreSQLConnection(
      '172.30.1.100', // PostgreSQL 서버 주소 (로컬호스트)
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
  }) async {
    final result = await _connection.query(
      '''
    INSERT INTO expenses (category, amount, time, is_budget_addition)
    VALUES (@category, @amount, @time, @is_budget_addition)
    RETURNING id
    ''',
      substitutionValues: {
        'category': category,
        'amount': amount,
        'time': time.toUtc(),
        'is_budget_addition': isBudgetAddition,
      },
    );

    return result.first[0] as int; // 새로 생성된 id 반환
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final results = await _connection.mappedResultsQuery(
      'SELECT id, category, amount, time, is_budget_addition FROM expenses ORDER BY time DESC',
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

  Future<void> deleteByCategory(String category) async {
    await _connection.query(
      'DELETE FROM expenses WHERE category = @category',
      substitutionValues: {'category': category},
    );
    print('Expenses with category "$category" deleted from the database');
  }

  Future<void> close() async {
    await _connection.close();
    print('PostgreSQL 연결 종료');
  }
}
