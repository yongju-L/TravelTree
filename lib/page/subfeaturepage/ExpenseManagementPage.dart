import 'package:flutter/material.dart';
import 'package:traveltree/page/subfeaturepage/StatisticsPage.dart';
import 'package:traveltree/widgets/AppDrawer.dart';
import 'package:traveltree/widgets/ExpenseInputModal.dart';
import 'package:traveltree/widgets/BudgetInputModal.dart';

class ExpenseManagementPage extends StatefulWidget {
  const ExpenseManagementPage({super.key});

  @override
  _ExpenseManagementPageState createState() => _ExpenseManagementPageState();
}

class _ExpenseManagementPageState extends State<ExpenseManagementPage> {
  double _totalBudget = 0.0;
  double _remainingBudget = 0.0;
  double _totalSpent = 0.0;
  final List<Map<String, dynamic>> _expenses = [];

  final Map<String, IconData> categoryIcons = {
    '음식': Icons.restaurant,
    '쇼핑': Icons.shopping_bag,
    '교통': Icons.directions_bus,
    '관광': Icons.camera_alt,
    '숙박': Icons.hotel,
    '항공': Icons.flight,
    '엔터': Icons.movie,
    '기타': Icons.create,
  };

  void _openBudgetModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BudgetInputModal(
          onTotalBudgetSet: (newBudget) {
            setState(() {
              _totalBudget = newBudget;
              _remainingBudget = _totalBudget - _totalSpent;
            });
          },
          onAdditionalBudgetAdded: (additionalBudget) {
            setState(() {
              _totalBudget += additionalBudget;
              _remainingBudget += additionalBudget;
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
          onExpenseAdded: (amount, category) {
            setState(() {
              _expenses.add({
                'amount': amount,
                'category': category,
                'time': DateTime.now().toLocal().toString().substring(11, 16),
              });
              _totalSpent += amount;
              _remainingBudget = _totalBudget - _totalSpent;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('경비관리'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: OutlinedButton(
              onPressed: _openBudgetModal,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                side:
                    const BorderSide(color: Colors.black, width: 1.0), // 얇은 테두리
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
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '총 지출 비용: ₩${_totalSpent.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18),
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
                  return ListTile(
                    leading: Icon(
                      categoryIcons[expense['category']] ?? Icons.error,
                      color: Colors.black,
                    ),
                    title: Text(expense['category']),
                    subtitle: Text('₩${expense['amount'].toStringAsFixed(0)}'),
                    trailing: Text(expense['time'] ?? '--:--'),
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
              onPressed: () {
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
              },
            ),
            FloatingActionButton(
              onPressed: _addExpense,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            ),
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                // 현황 페이지 이동 예정
              },
            ),
          ],
        ),
      ),
    );
  }
}
