import 'package:flutter/material.dart';

class ExpenseInputModal extends StatefulWidget {
  final Function(double, String) onExpenseAdded;

  const ExpenseInputModal({super.key, required this.onExpenseAdded});

  @override
  _ExpenseInputModalState createState() => _ExpenseInputModalState();
}

class _ExpenseInputModalState extends State<ExpenseInputModal> {
  double? inputExpense;
  String selectedCategory = '음식';
  String selectedCurrency = 'KRW'; // 기본 통화는 KRW
  final Map<String, IconData> categories = {
    '음식': Icons.restaurant,
    '쇼핑': Icons.shopping_bag,
    '교통': Icons.directions_bus,
    '관광': Icons.camera_alt,
    '숙박': Icons.hotel,
    '항공': Icons.flight,
    '엔터': Icons.movie,
    '기타': Icons.create, // 직접 입력
  };

  final double _exchangeRate = 1300; // 예시: 1 USD = 1300 KRW

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // 키보드 대응
      child: FractionallySizedBox(
        heightFactor: 0.7,
        child: SingleChildScrollView(
          // overflow 방지
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '지출 추가',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(hintText: '지출 금액을 입력하세요'),
                        onChanged: (value) {
                          inputExpense = double.tryParse(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedCurrency,
                      items: const [
                        DropdownMenuItem(value: 'KRW', child: Text('₩ KRW')),
                        DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCurrency = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '지출 카테고리 선택:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: categories.entries.map((entry) {
                    return ChoiceChip(
                      label: Text(entry.key),
                      avatar: Icon(entry.value),
                      selected: selectedCategory == entry.key,
                      onSelected: (selected) {
                        if (entry.key == '기타' && selected) {
                          _showCustomCategoryDialog();
                        } else {
                          _selectCategory(entry.key);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (inputExpense != null && inputExpense! > 0) {
                      double convertedExpense = inputExpense!;
                      if (selectedCurrency == 'USD') {
                        convertedExpense *= _exchangeRate; // USD -> KRW 환전
                      }
                      widget.onExpenseAdded(convertedExpense, selectedCategory);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('추가'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomCategoryDialog() {
    String? customCategory;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('기타 항목 입력'),
          content: TextField(
            decoration: const InputDecoration(hintText: '항목을 입력하세요'),
            onChanged: (value) {
              customCategory = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (customCategory != null && customCategory!.isNotEmpty) {
                  _selectCategory(customCategory!);
                  Navigator.pop(context);
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
