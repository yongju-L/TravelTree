import 'package:flutter/material.dart';
import 'package:traveltree/helpers/ExpenseDatabaseHelper.dart';
import 'package:traveltree/travelpage/subfeaturepage/CalendarPage.dart';
import 'package:traveltree/travelpage/subfeaturepage/StatisticsPage.dart';

class ViewExpenseManagementPage extends StatefulWidget {
  final int travelId;

  const ViewExpenseManagementPage({super.key, required this.travelId});

  @override
  _ViewExpenseManagementPageState createState() =>
      _ViewExpenseManagementPageState();
}

class _ViewExpenseManagementPageState extends State<ViewExpenseManagementPage> {
  final ExpenseDatabaseHelper _databaseHelper = ExpenseDatabaseHelper();
  List<Map<String, dynamic>> _expenses = [];
  double _totalSpent = 0.0;
  double _totalBudget = 0.0;
  double _remainingBudget = 0.0;
  DateTime _selectedDate = DateTime.now();

  final Map<String, IconData> categoryIcons = {
    '음식': Icons.restaurant,
    '쇼핑': Icons.shopping_bag,
    '교통': Icons.directions_bus,
    '관광': Icons.camera_alt,
    '숙박': Icons.hotel,
    '항공': Icons.flight,
    '엔터': Icons.movie,
    '기타': Icons.create,
    '경비 추가': Icons.attach_money,
  };

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    await _databaseHelper.connect();
    final expenses = await _databaseHelper.getExpensesByDateAndTravelId(
      _selectedDate,
      widget.travelId,
    );

    double totalSpent = 0.0;
    double totalBudget = 0.0;

    for (var expense in expenses) {
      final amount = double.tryParse(expense['amount'].toString()) ?? 0.0;
      if (expense['category'] == '총 경비') {
        totalBudget = amount;
      } else if (expense['is_budget_addition'] == true) {
        totalBudget += amount;
      } else {
        totalSpent += amount;
      }
    }

    setState(() {
      _expenses =
          expenses.where((expense) => expense['category'] != '총 경비').toList();
      _totalSpent = totalSpent;
      _totalBudget = totalBudget;
      _remainingBudget = totalBudget - totalSpent;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarPage()),
    );

    if (selectedDate != null && selectedDate is DateTime) {
      setState(() {
        _selectedDate = selectedDate;
      });
      await _loadDataFromDatabase();
    }
  }

  void _navigateToStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsPage(
          totalBudget: _totalBudget,
          totalSpent: _totalSpent,
          remainingBudget: _remainingBudget,
          expenses: _expenses,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('경비 보기'),
            const SizedBox(width: 8),
            Text(
              '(${_selectedDate.month}-${_selectedDate.day})',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet,
                        color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      '총 경비: ₩${_totalBudget.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Text(
                  '남은 경비: ₩${_remainingBudget.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  final expense = _expenses[index];
                  final isBudgetAddition = expense['is_budget_addition'];
                  final double amount =
                      double.tryParse(expense['amount'].toString()) ?? 0.0;
                  final displayAmount = isBudgetAddition
                      ? "+₩${amount.toStringAsFixed(0)}"
                      : "-₩${amount.toStringAsFixed(0)}";

                  return ListTile(
                    leading: Icon(
                      categoryIcons[expense['category']] ?? Icons.error,
                      color: Colors.black,
                    ),
                    title: Text(expense['category']),
                    subtitle: Text(
                      displayAmount,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isBudgetAddition ? Colors.red : Colors.blue,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: _navigateToStatistics,
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context),
            ),
          ],
        ),
      ),
    );
  }
}
