import 'package:flutter/material.dart';
import 'package:traveltree/helpers/ScheduleDatabaseHelper.dart';
import 'package:traveltree/travelpage/subfeaturepage/CalendarPage.dart';
import 'package:traveltree/travelpage/subfeaturepage/WeeklySchedulePage.dart';

class ViewScheduleManagementPage extends StatefulWidget {
  final int travelId; // travelId 추가

  const ViewScheduleManagementPage({super.key, required this.travelId});

  @override
  _ViewScheduleManagementPageState createState() =>
      _ViewScheduleManagementPageState();
}

class _ViewScheduleManagementPageState
    extends State<ViewScheduleManagementPage> {
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _schedules = [];
  final ScheduleDatabaseHelper _dbHelper = ScheduleDatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initializeDB();
  }

  Future<void> _initializeDB() async {
    await _dbHelper.connect();
    final schedules = await _dbHelper.getSchedulesByDateAndTravelId(
      _selectedDate,
      widget.travelId,
    );

    setState(() {
      _schedules.clear();
      _schedules.addAll(schedules.map((schedule) {
        return {
          'id': schedule['id'],
          'title': schedule['title'],
          'content': schedule['content'],
          'completed': schedule['completed'],
        };
      }).toList());
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
      _initializeDB();
    }
  }

  void _navigateToWeeklySchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeeklySchedulePage(travelId: widget.travelId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 보기'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          return ListTile(
            leading: Icon(
              schedule['completed']
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: schedule['completed'] ? Colors.blue : null,
            ),
            title: Text(
              schedule['title'],
              style: TextStyle(
                decoration:
                    schedule['completed'] ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              schedule['content'].length > 14
                  ? schedule['content'].substring(0, 14)
                  : schedule['content'],
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _navigateToWeeklySchedule,
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
