import 'package:flutter/material.dart';

class BudgetInputModal extends StatefulWidget {
  final Function(double) onTotalBudgetSet;
  final Function(double) onAdditionalBudgetAdded;

  const BudgetInputModal({
    super.key,
    required this.onTotalBudgetSet,
    required this.onAdditionalBudgetAdded,
  });

  @override
  _BudgetInputModalState createState() => _BudgetInputModalState();
}

class _BudgetInputModalState extends State<BudgetInputModal> {
  double? inputAmount;
  String selectedOption = '총 여행 경비 입력'; // 기본 옵션
  String selectedCurrency = 'KRW'; // 기본 통화는 KRW
  final List<String> options = ['총 여행 경비 입력', '여행 경비 추가'];
  final double _exchangeRate = 1300; // 예시 환율: 1 USD = 1300 KRW

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '경비 입력',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: options.map((option) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedOption = option;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedOption == option
                                  ? Colors.black
                                  : Colors.white,
                              borderRadius: option == '총 여행 경비 입력'
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    )
                                  : const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                color: selectedOption == option
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: selectedOption == '총 여행 경비 입력'
                              ? '총 여행 경비를 입력하세요'
                              : '추가 경비를 입력하세요',
                        ),
                        onChanged: (value) {
                          inputAmount = double.tryParse(value);
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    if (inputAmount != null && inputAmount! > 0) {
                      double convertedAmount = inputAmount!;
                      if (selectedCurrency == 'USD') {
                        convertedAmount *= _exchangeRate; // USD -> KRW 환전
                      }
                      if (selectedOption == '총 여행 경비 입력') {
                        widget.onTotalBudgetSet(convertedAmount);
                      } else {
                        widget.onAdditionalBudgetAdded(convertedAmount);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('확인'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
