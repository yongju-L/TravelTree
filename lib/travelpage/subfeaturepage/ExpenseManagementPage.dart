import 'package:flutter/material.dart';
import 'package:traveltree/travelpage/subfeaturepage/StatisticsPage.dart';
import 'package:traveltree/widgets/AppDrawer.dart';
import 'package:traveltree/widgets/ExpenseInputModal.dart';
import 'package:traveltree/widgets/BudgetInputModal.dart';
import 'package:traveltree/travelpage/subfeaturepage/CalendarPage.dart';
import 'package:traveltree/helpers/ExpenseDatabaseHelper.dart';

class ExpenseManagementPage extends StatefulWidget {
  final int travelId; // travelId 추가

  const ExpenseManagementPage({super.key, required this.travelId});

  @override
  _ExpenseManagementPageState createState() => _ExpenseManagementPageState();
}

class _ExpenseManagementPageState extends State<ExpenseManagementPage> {
  DateTime _selectedDate = DateTime.now();
  double _totalBudget = 0.0;
  double _remainingBudget = 0.0;
  double _totalSpent = 0.0;
  final List<Map<String, dynamic>> _expenses = [];
  final ExpenseDatabaseHelper _databaseHelper = ExpenseDatabaseHelper();

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
    List<Map<String, dynamic>> dbExpenses =
        await _databaseHelper.getExpensesByDateAndTravelId(
            _selectedDate, widget.travelId); // travelId 사용

    double totalSpent = 0.0;
    double totalBudget = 0.0;

    for (var expense in dbExpenses) {
      double amount = double.tryParse(expense['amount'].toString()) ?? 0.0;

      if (expense['category'] == '총 경비') {
        totalBudget = amount;
      } else if (expense['is_budget_addition'] == true) {
        totalBudget += amount;
      } else {
        totalSpent += amount;
      }
    }

    setState(() {
      _expenses.clear();
      _expenses.addAll(dbExpenses
          .where((expense) => expense['category'] != '총 경비')
          .toList());
      _totalSpent = totalSpent;
      _totalBudget = totalBudget;
      _remainingBudget = _totalBudget - _totalSpent;
    });
  }

  void _openBudgetModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BudgetInputModal(
          onTotalBudgetSet: (newBudget) async {
            await _databaseHelper.deleteByCategoryAndDateAndTravelId(
                '총 경비', _selectedDate, widget.travelId); // travelId 사용

            final newId = await _databaseHelper.insertExpense(
              category: '총 경비',
              amount: newBudget,
              time: DateTime.now(),
              isBudgetAddition: true,
              date: _selectedDate,
              travelId: widget.travelId, // travelId 전달
            );

            print('새 총 경비 저장 완료: ID = $newId');

            setState(() {
              _totalBudget = newBudget;
              _remainingBudget = _totalBudget - _totalSpent;
            });
          },
          onAdditionalBudgetAdded: (additionalBudget) async {
            final newId = await _databaseHelper.insertExpense(
              category: '경비 추가',
              amount: additionalBudget,
              time: DateTime.now(),
              isBudgetAddition: true,
              date: _selectedDate,
              travelId: widget.travelId, // travelId 전달
            );

            final updatedTotalBudget = _totalBudget + additionalBudget;
            await _databaseHelper.updateTotalBudget(
                updatedTotalBudget, _selectedDate, widget.travelId);

            setState(() {
              _totalBudget = updatedTotalBudget;
              _remainingBudget += additionalBudget;

              _expenses.insert(
                0,
                {
                  'id': newId,
                  'category': '경비 추가',
                  'amount': additionalBudget,
                  'time': DateTime.now().toLocal().toString().substring(11, 16),
                  'is_budget_addition': true,
                },
              );
            });
          },
        );
      },
    );
  }

  void _addExpense() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ExpenseInputModal(
          onExpenseAdded: (amount, category) async {
            final newId = await _databaseHelper.insertExpense(
              category: category,
              amount: amount,
              time: DateTime.now(),
              isBudgetAddition: false,
              date: _selectedDate,
              travelId: widget.travelId, // travelId 전달
            );

            setState(() {
              _expenses.insert(
                0,
                {
                  'id': newId,
                  'category': category,
                  'amount': amount,
                  'time': DateTime.now().toLocal().toString().substring(11, 16),
                  'is_budget_addition': false,
                },
              );
              _totalSpent += amount;
              _remainingBudget = _totalBudget - _totalSpent;
            });
          },
        );
      },
    );
  }

  void _deleteExpense(int id, int index) async {
    final expense = _expenses[index];

    await _databaseHelper.deleteExpense(id);
    setState(() {
      _expenses.removeAt(index);
      final amount = double.tryParse(expense['amount'].toString()) ?? 0.0;

      if (expense['is_budget_addition'] == true) {
        _totalBudget -= amount;
        _databaseHelper.updateTotalBudget(
            _totalBudget, _selectedDate, widget.travelId); // travelId 사용
      } else {
        _totalSpent -= amount;
      }

      _remainingBudget = _totalBudget - _totalSpent;
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
      _loadDataFromDatabase();
    }
  }

  void _navigateToStatistics() {
    if (_expenses.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("경고"),
          content: const Text("경비를 추가해 주세요."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("확인"),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatisticsPage(
            totalBudget: _totalBudget,
            totalSpent: _totalSpent,
            remainingBudget: _remainingBudget,
            expenses: _expenses
                .where((expense) => expense['is_budget_addition'] == false)
                .toList(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('경비관리'),
            const SizedBox(width: 8),
            Text(
              '(${_selectedDate.month}-${_selectedDate.day})', // 선택된 날짜 표시
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: OutlinedButton(
              onPressed: _openBudgetModal,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                side: const BorderSide(color: Colors.black, width: 1.0),
              ),
              child: const Text(
                '경비 입력',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      drawer: AppDrawer(travelId: widget.travelId), // AppDrawer에 travelId 전달
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

                  return GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("삭제 확인"),
                          content: const Text("이 항목을 삭제하시겠습니까?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("취소"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteExpense(expense['id'], index);
                              },
                              child: const Text("삭제"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: ListTile(
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
            FloatingActionButton(
              onPressed: _addExpense,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
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
