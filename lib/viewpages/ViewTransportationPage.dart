import 'package:flutter/material.dart';
import 'package:traveltree/helpers/TransportationDatabaseHelper.dart';

class ViewTransportationPage extends StatefulWidget {
  final int travelId;

  const ViewTransportationPage({Key? key, required this.travelId})
      : super(key: key);

  @override
  _ViewTransportationPageState createState() => _ViewTransportationPageState();
}

class _ViewTransportationPageState extends State<ViewTransportationPage> {
  final TransportationDatabaseHelper _dbHelper = TransportationDatabaseHelper();
  final List<String> _modes = [
    'Walking',
    'Driving',
    'Public Transport'
  ]; // 고정된 이동 수단
  Map<String, dynamic> _transportationData = {}; // DB에서 가져올 데이터
  bool _isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    _initializeDatabase(); // 페이지가 로드될 때 DB에서 데이터 불러오기
  }

  Future<void> _initializeDatabase() async {
    await _dbHelper.connect(); // 데이터베이스 연결
    await _loadTransportationData(); // 데이터 로드
  }

  // DB에서 이동 수단 데이터를 불러오기
  Future<void> _loadTransportationData() async {
    try {
      final data = await _dbHelper.getTransportationData(widget.travelId);

      // 고정된 이동 수단(_modes)을 기준으로 데이터를 초기화
      Map<String, dynamic> initialData = {
        for (var mode in _modes) mode: {'distance': 0.0, 'duration': 0}
      };

      // DB에서 가져온 데이터를 초기 값에 병합
      for (var entry in data) {
        initialData[entry['mode']] = {
          'distance': entry['distance'] ?? 0.0,
          'duration': entry['duration'] ?? 0,
        };
      }

      setState(() {
        _transportationData = initialData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading transportation data: $e');
      setState(() {
        _isLoading = false; // 로딩 중 오류 발생 시 로딩 상태 해제
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이동 통계'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _modes.length, // 고정된 이동 수단 개수 사용
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              itemBuilder: (context, index) {
                String mode = _modes[index];
                var data = _transportationData[mode] ??
                    {'distance': 0.0, 'duration': 0};

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 14.0),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 아이콘
                        CircleAvatar(
                          radius: 24, // 아이콘 크기 조정
                          backgroundColor: Colors.black.withOpacity(0.1),
                          child: Icon(
                            _getModeIcon(mode),
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16), // 간격 조정
                        // 텍스트
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getModeKorean(mode),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '거리: ${data["distance"].toStringAsFixed(1)} km | 시간: ${_formatDuration(data["duration"])}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // 이동수단에 따른 아이콘
  IconData _getModeIcon(String mode) {
    switch (mode) {
      case 'Walking':
        return Icons.directions_walk;
      case 'Driving':
        return Icons.directions_car;
      case 'Public Transport':
        return Icons.directions_bus;
      default:
        return Icons.help_outline;
    }
  }

  // 이동수단에 따른 한국어 이름
  String _getModeKorean(String mode) {
    switch (mode) {
      case 'Walking':
        return '도보';
      case 'Driving':
        return '운전';
      case 'Public Transport':
        return '대중교통';
      default:
        return '기타';
    }
  }

  // 시간을 포맷팅 (초 -> 시:분)
  String _formatDuration(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours시간 $minutes분';
    } else {
      return '$minutes분';
    }
  }
}
