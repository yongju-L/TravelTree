import 'package:flutter/material.dart';
import 'package:traveltree/helpers/ScheduleDatabaseHelper.dart';
import 'package:traveltree/travelpage/subfeaturepage/CalendarPage.dart';
import 'package:traveltree/travelpage/subfeaturepage/WeeklySchedulePage.dart';
import 'package:traveltree/widgets/AppDrawer.dart';

class ScheduleManagementPage extends StatefulWidget {
  final int travelId; // travelId 추가

  const ScheduleManagementPage({super.key, required this.travelId});

  @override
  _ScheduleManagementPageState createState() => _ScheduleManagementPageState();
}

class _ScheduleManagementPageState extends State<ScheduleManagementPage> {
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _schedules = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDB();
  }

  Future<void> _initializeDB() async {
    final dbHelper = ScheduleDatabaseHelper();
    await dbHelper.connect();

    final schedules = await dbHelper.getSchedulesByDateAndTravelId(
      _selectedDate, // 정확한 날짜 사용
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

  void _addSchedule(String title, String content) async {
    final dbHelper = ScheduleDatabaseHelper();
    await dbHelper.connect();

    final id = await dbHelper.insertSchedule(
      title: title,
      content: content,
      completed: false,
      date: _selectedDate,
      travelId: widget.travelId,
    );

    setState(() {
      _schedules.add({
        'id': id,
        'title': title,
        'content': content,
        'completed': false,
        'date': _selectedDate, // 그대로 로컬 날짜 저장
      });
    });

    _titleController.clear();
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const CalendarPage()), // 달력 페이지 이동
    );

    if (selectedDate != null && selectedDate is DateTime) {
      setState(() {
        _selectedDate = selectedDate;
      });
      _initializeDB(); // 데이터 다시 로드
    }
  }

  void _showScheduleDetails(Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            schedule['title'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '내용: ${schedule['content']}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
            ElevatedButton(
              onPressed: () async {
                final dbHelper = ScheduleDatabaseHelper();
                await dbHelper.connect();

                // DB에서 삭제
                await dbHelper.deleteSchedule(schedule['id']);

                // UI 갱신
                await _initializeDB();

                // 다이얼로그 닫기
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _toggleCompletion(int index) async {
    final schedule = _schedules[index];
    final newCompletedState = !schedule['completed'];

    final dbHelper = ScheduleDatabaseHelper();
    await dbHelper.connect();

    // DB에서 완료 상태 업데이트
    await dbHelper.updateSchedule(
      id: schedule['id'],
      title: schedule['title'],
      content: schedule['content'],
      completed: newCompletedState,
      date: _selectedDate,
      travelId: widget.travelId,
    );

    // UI 갱신
    setState(() {
      _schedules[index]['completed'] = newCompletedState;
    });
  }

  void _showAddScheduleBottomSheet() {
    // 필드 초기화
    _titleController.clear();
    _contentController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '일정 추가',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '제목'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: '내용'),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.isNotEmpty) {
                          _addSchedule(
                            _titleController.text,
                            _contentController.text,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('추가'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정관리'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      drawer: AppDrawer(travelId: widget.travelId),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          return ListTile(
            leading: GestureDetector(
              onTap: () => _toggleCompletion(index),
              child: Icon(
                schedule['completed']
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: schedule['completed'] ? Colors.blue : null,
              ),
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
            onLongPress: () => _showScheduleDetails(schedule),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WeeklySchedulePage(travelId: widget.travelId),
                  ),
                );
              },
            ),
            FloatingActionButton(
              onPressed: _showAddScheduleBottomSheet,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                _selectDate(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
