import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class StatisticsPage extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final double remainingBudget;
  final List<Map<String, dynamic>> expenses;

  StatisticsPage({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.remainingBudget,
    required this.expenses,
  });

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

  Map<String, double> _generateChartData() {
    Map<String, double> data = {};

    for (var expense in expenses) {
      // 금액을 double로 변환하여 합산
      double amount = double.tryParse(expense['amount'].toString()) ?? 0.0;
      data[expense['category']] = (data[expense['category']] ?? 0) + amount;
    }

    if (remainingBudget > 0) {
      data['남은 경비'] = remainingBudget;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _generateChartData();
    final totalValue = remainingBudget > 0 ? totalBudget : totalSpent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Pie Chart
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PieChart(
                dataMap: chartData,
                chartType: ChartType.ring,
                baseChartColor: Colors.grey[200]!,
                totalValue: totalValue,
                chartRadius: MediaQuery.of(context).size.width / 2,
                ringStrokeWidth: 30,
                legendOptions: const LegendOptions(
                  showLegendsInRow: false,
                  legendPosition: LegendPosition.right,
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValuesInPercentage: true,
                  showChartValuesOutside: false,
                ),
              ),
            ),
          ),
          const Divider(height: 2, color: Colors.black),
          // Remaining Budget
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                Text(
                  '남은 경비: ₩${remainingBudget.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: remainingBudget > 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '총 지출 금액: ₩${totalSpent.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          // List of Expenses
          Expanded(
            flex: 4,
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                final amount =
                    double.tryParse(expense['amount'].toString()) ?? 0.0;

                return ListTile(
                  leading: Icon(
                    categoryIcons[expense['category']] ?? Icons.error,
                    color: Colors.black,
                  ),
                  title: Text(expense['category']),
                  subtitle: Text(
                    "₩${amount.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
