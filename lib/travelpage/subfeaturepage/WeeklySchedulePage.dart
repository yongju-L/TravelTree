import 'package:flutter/material.dart';
import 'package:traveltree/helpers/ScheduleDatabaseHelper.dart';

class WeeklySchedulePage extends StatefulWidget {
  final int travelId; // travelId 추가

  const WeeklySchedulePage({super.key, required this.travelId});

  @override
  _WeeklySchedulePageState createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage> {
  final ScheduleDatabaseHelper _dbHelper = ScheduleDatabaseHelper();
  final List<Map<String, dynamic>> _weeklySchedules = [];

  @override
  void initState() {
    super.initState();
    _loadWeeklySchedules();
  }

  Future<void> _loadWeeklySchedules() async {
    await _dbHelper.connect();

    final startOfWeek = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    ); // 이번 주의 첫 번째 날

    final List<Map<String, dynamic>> schedules = [];

    for (int i = 0; i <= 6; i++) {
      final currentDate = startOfWeek.add(Duration(days: i));
      final dailySchedules = await _dbHelper.getSchedulesByDateAndTravelId(
        currentDate,
        widget.travelId, // travelId 사용
      );

      for (final schedule in dailySchedules) {
        schedules.add({
          ...schedule,
          'displayDate': currentDate, // 표시할 날짜 추가
        });
      }
    }

    setState(() {
      _weeklySchedules.clear();
      _weeklySchedules.addAll(schedules);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일주일 일정'),
      ),
      body: _weeklySchedules.isEmpty
          ? const Center(child: Text('일정이 없습니다.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _weeklySchedules.length,
              itemBuilder: (context, index) {
                final schedule = _weeklySchedules[index];
                final date = DateTime.parse(schedule['displayDate'].toString());

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Stack(
                    alignment: Alignment.center, // 정중앙 정렬
                    children: [
                      // 배경색 처리
                      if (schedule['completed'])
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.lightGreenAccent.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          height: 80,
                        ),
                      ListTile(
                        title: Text(
                          schedule['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: schedule['completed']
                                ? Colors.green[700]
                                : Colors.black,
                          ),
                        ),
                        subtitle: Text(schedule['content']),
                        trailing: Text(
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      // 중앙 체크 아이콘
                      if (schedule['completed'])
                        const Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.check_circle,
                              size: 36.0, // 중간 크기
                              color: Colors.green, // 초록색 아이콘
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
