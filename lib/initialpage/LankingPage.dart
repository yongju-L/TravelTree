import 'package:flutter/material.dart';
import 'package:traveltree/helpers/SnsDatabaseHelper.dart';
import 'package:traveltree/widgets/InitialNavigation.dart';

class LankingPage extends StatefulWidget {
  final int userId;

  const LankingPage({Key? key, required this.userId}) : super(key: key);

  @override
  _LankingPageState createState() => _LankingPageState();
}

class _LankingPageState extends State<LankingPage> {
  final SnsDatabaseHelper _snsDbHelper = SnsDatabaseHelper();
  List<Map<String, dynamic>> _rankedList = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await _snsDbHelper.connect();
    await _fetchRankingData();
  }

  Future<void> _fetchRankingData() async {
    final rankings = await _snsDbHelper.getRankedTravels();
    setState(() {
      _rankedList = rankings;
    });
  }

  @override
  void dispose() {
    _snsDbHelper.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '랭킹 페이지',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: _rankedList.isEmpty
          ? const Center(
              child: Text(
                '랭킹 데이터를 불러오는 중입니다...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _rankedList.length,
              itemBuilder: (context, index) {
                final rank = index + 1;
                final data = _rankedList[index];
                final String username = data['username'];
                final String travelName = data['travel_name'];
                final int totalLikes = data['total_likes'] ?? 0;

                // 크기와 테두리 설정
                double fontSize;
                double padding;
                Border border;

                if (rank == 1) {
                  fontSize = 24.0; // 1등 가장 큰 크기
                  padding = 20.0;
                  border = Border.all(color: Colors.amber, width: 3);
                } else if (rank == 2) {
                  fontSize = 22.0; // 2등 약간 작은 크기
                  padding = 18.0;
                  border = Border.all(color: Colors.grey, width: 2);
                } else if (rank == 3) {
                  fontSize = 20.0; // 3등 더 작은 크기
                  padding = 16.0;
                  border = Border.all(color: Colors.brown, width: 1.5);
                } else {
                  fontSize = 18.0; // 나머지는 기본 크기
                  padding = 14.0;
                  border = Border.all(color: Colors.grey[300]!, width: 1);
                }

                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                    border: border,
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white, // 테두리 안쪽은 흰색으로 설정
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$rank위',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: rank == 1
                              ? Colors.amber
                              : rank == 2
                                  ? Colors.grey
                                  : rank == 3
                                      ? Colors.brown
                                      : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '작성자: $username',
                              style: TextStyle(
                                fontSize: fontSize - 4,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '여행 이름: $travelName',
                              style: TextStyle(fontSize: fontSize - 6),
                            ),
                            Text(
                              '받은 좋아요 수: $totalLikes개',
                              style: TextStyle(
                                fontSize: fontSize - 6,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar:
          buildInitialBottomNavigationBar(context, 2, widget.userId),
    );
  }
}
