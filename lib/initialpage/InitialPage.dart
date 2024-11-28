import 'package:flutter/material.dart';
import 'package:traveltree/helpers/InitialDatabaseHelper.dart';
import 'package:traveltree/travelpage/mainpage/MainPage.dart';
import 'package:traveltree/widgets/AddTripModal.dart';
import 'package:traveltree/widgets/InitialNavigation.dart';
import 'package:traveltree/loginpage/LoginPage.dart';

class InitialPage extends StatefulWidget {
  final int userId;

  const InitialPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final InitialDatabaseHelper _dbHelper = InitialDatabaseHelper();
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await _dbHelper.connect();
      await _fetchTrips();
    } catch (e) {
      print('Database initialization error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTrips() async {
    try {
      final trips = await _dbHelper.getTrips(widget.userId);
      setState(() {
        _trips = trips;
      });
    } catch (e) {
      print('Error fetching trips: $e');
    }
  }

  Future<void> _deleteTrip(int tripId) async {
    try {
      await _dbHelper.deleteTrip(tripId);
      await _fetchTrips();
    } catch (e) {
      print('Error deleting trip: $e');
    }
  }

  Future<void> _showDeleteDialog(int tripId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('이 여행을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // 다이얼로그 닫기
                await _deleteTrip(tripId); // 여행 삭제
              },
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddTripModal() async {
    await AddTripModal.showAddTripModal(context, _fetchTrips, widget.userId);
  }

  String _formatDateRange(String startDate, String endDate) {
    final start = DateTime.parse(startDate).toLocal();
    final end = DateTime.parse(endDate).toLocal();
    return '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')} ~ ${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
  }

  void _navigateToLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _navigateToTravelPage(int travelId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(
          travelId: travelId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _navigateToLoginPage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _trips.isEmpty
                    ? const Center(child: Text('저장된 여행이 없습니다.'))
                    : ListView.builder(
                        itemCount: _trips.length,
                        itemBuilder: (context, index) {
                          final trip = _trips[index];
                          return GestureDetector(
                            onTap: () => _navigateToTravelPage(
                                trip['id']), // 클릭 시 여행 페이지로 이동
                            onLongPress: () =>
                                _showDeleteDialog(trip['id']), // 삭제 다이얼로그 호출
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: ListTile(
                                title: Text(trip['name']),
                                subtitle: Text(trip['country']),
                                trailing: Text(
                                  _formatDateRange(
                                      trip['start_date'], trip['end_date']),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showAddTripModal,
              child: const Text('여행 추가'),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          buildInitialBottomNavigationBar(context, 0, widget.userId),
    );
  }
}
