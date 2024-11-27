import 'package:flutter/material.dart';
import 'package:traveltree/page/subfeaturepage/CalendarPage.dart';
import 'package:traveltree/widgets/AppDrawer.dart';

class ScheduleManagementPage extends StatefulWidget {
  const ScheduleManagementPage({super.key});

  @override
  _ScheduleManagementPageState createState() => _ScheduleManagementPageState();
}

class _ScheduleManagementPageState extends State<ScheduleManagementPage> {
  final List<Map<String, dynamic>> _schedules = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  void _addSchedule(String title, String content) {
    setState(() {
      _schedules.add({
        'title': title,
        'content': content,
        'startTime': _startTime,
        'endTime': _endTime,
        'completed': false,
      });
    });
    _titleController.clear();
    _contentController.clear();
    _startTime = null;
    _endTime = null;
  }

  void _showScheduleDetails(Map<String, dynamic> schedule) {
    final String startTime = schedule['startTime'] != null
        ? '${schedule['startTime'].hour.toString().padLeft(2, '0')}:${schedule['startTime'].minute.toString().padLeft(2, '0')}'
        : 'N/A';
    final String endTime = schedule['endTime'] != null
        ? '${schedule['endTime'].hour.toString().padLeft(2, '0')}:${schedule['endTime'].minute.toString().padLeft(2, '0')}'
        : 'N/A';

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
              const SizedBox(height: 10),
              Text(
                '시작 시간: $startTime',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                '마감 시간: $endTime',
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
          ],
        );
      },
    );
  }

  void _toggleCompletion(int index) {
    setState(() {
      final toggledItem = _schedules[index];
      final wasCompleted = toggledItem['completed'];
      toggledItem['completed'] = !wasCompleted;
      _schedules.removeAt(index); // 기존 위치에서 제거

      if (wasCompleted) {
        // 체크 표시가 되어 있었는데 해제된 경우, 맨 앞에 추가
        _schedules.insert(0, toggledItem);
      } else {
        // 체크 표시가 안 되어 있다가 설정된 경우, 맨 뒤에 추가
        _schedules.add(toggledItem);
      }
    });
  }

  Future<void> _pickTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  void _showAddScheduleBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _pickTime(context, true),
                            child: Text(
                              _startTime == null
                                  ? '시작 시간 선택'
                                  : '시작: ${_startTime!.format(context)}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _pickTime(context, false),
                            child: Text(
                              _endTime == null
                                  ? '마감 시간 선택'
                                  : '마감: ${_endTime!.format(context)}',
                            ),
                          ),
                        ),
                      ],
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
      drawer: const AppDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          final startTime = schedule['startTime'] as TimeOfDay?;
          final endTime = schedule['endTime'] as TimeOfDay?;
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
            trailing: startTime != null && endTime != null
                ? Text(
                    '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} ~ ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  )
                : null,
            onLongPress: () =>
                _showScheduleDetails(schedule), // 꾹 눌렀을 때 세부 정보 표시
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.list), onPressed: () {}),
            FloatingActionButton(
              onPressed: _showAddScheduleBottomSheet,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarPage()),
                );
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
