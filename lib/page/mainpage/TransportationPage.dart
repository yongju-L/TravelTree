import 'package:flutter/material.dart';

class TransportationPage extends StatelessWidget {
  final Map<String, dynamic> transportationData;

  const TransportationPage({super.key, required this.transportationData});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5, // 높이를 40%로 설정
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 상단 헤더
            Container(
              height: 50, // 헤더 크기 조정
              alignment: Alignment.center,
              child: const Text(
                '이동 통계',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1, color: Colors.grey),

            // 데이터 리스트
            Expanded(
              child: ListView.builder(
                itemCount: transportationData.length,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                itemBuilder: (context, index) {
                  String mode = transportationData.keys.elementAt(index);
                  var data = transportationData[mode];
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
                            backgroundColor:
                                Colors.black.withOpacity(0.1), // 연한 블랙 배경
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
            ),
          ],
        ),
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
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }
}
