import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 날짜 및 시간 데이터를 한국어로 초기화
    initializeDateFormatting('ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('달력'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          locale: 'ko_KR', // 한국어 설정
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: DateTime.now(),
          calendarFormat: CalendarFormat.month, // 월간 보기로 고정
          headerStyle: const HeaderStyle(
            formatButtonVisible: false, // "주" 버튼 비활성화
            titleCentered: true,
            titleTextStyle:
                TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            weekendStyle:
                TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            weekendTextStyle: TextStyle(color: Colors.red),
          ),
          onDaySelected: (selectedDay, _) {
            Navigator.pop(context, selectedDay); // 선택한 날짜 반환
          },
        ),
      ),
    );
  }
}
