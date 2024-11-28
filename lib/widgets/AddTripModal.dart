import 'package:flutter/material.dart';
import 'package:traveltree/helpers/InitialDatabaseHelper.dart';

class AddTripModal {
  static Future<void> showAddTripModal(
      BuildContext context, Function onTripAdded, int userId) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController countryController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    final InitialDatabaseHelper dbHelper = InitialDatabaseHelper();

    Future<void> selectDate(BuildContext context, bool isStartDate) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        locale: const Locale('ko', 'KR'),
      );

      if (picked != null) {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '여행 추가',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '여행 이름'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: countryController,
                decoration: const InputDecoration(labelText: '여행 국가'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => selectDate(context, true),
                      child: Text(
                        startDate == null
                            ? '시작 날짜 선택'
                            : '시작: ${startDate!.toLocal()}'.split(' ')[0],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => selectDate(context, false),
                      child: Text(
                        endDate == null
                            ? '종료 날짜 선택'
                            : '종료: ${endDate!.toLocal()}'.split(' ')[0],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      countryController.text.isEmpty ||
                      startDate == null ||
                      endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('모든 필드를 입력해주세요.')),
                    );
                    return;
                  }

                  try {
                    if (!dbHelper.isConnected) {
                      // 연결 확인 메서드 추가
                      await dbHelper.connect();
                    }
                    await dbHelper.insertTrip(
                      name: nameController.text.trim(),
                      country: countryController.text.trim(),
                      startDate: startDate!,
                      endDate: endDate!,
                      userId: userId,
                    );
                    Navigator.pop(context);
                    onTripAdded();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding trip: $e')),
                    );
                  }
                },
                child: const Text('여행 추가'),
              ),
            ],
          ),
        );
      },
    );
  }
}
