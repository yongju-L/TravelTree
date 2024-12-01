import 'package:flutter/material.dart';
import 'package:traveltree/helpers/InitialDatabaseHelper.dart';
import 'package:traveltree/helpers/SnsDatabaseHelper.dart';
import 'package:traveltree/viewpages/ViewMainPage.dart';
import 'package:traveltree/widgets/InitialNavigation.dart';

class SnsPage extends StatefulWidget {
  final int userId;

  const SnsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _SnsPageState createState() => _SnsPageState();
}

class _SnsPageState extends State<SnsPage> {
  final List<Map<String, dynamic>> _uploadedTravels = []; // SNS에 업로드된 여행 목록
  final InitialDatabaseHelper _initdbHelper =
      InitialDatabaseHelper(); // 초기 DB 헬퍼
  final SnsDatabaseHelper _snsDbHelper = SnsDatabaseHelper(); // SNS DB 헬퍼

  @override
  void initState() {
    super.initState();
    _initializeDatabase(); // 데이터베이스 초기화
  }

  Future<void> _initializeDatabase() async {
    await _initdbHelper.connect(); // 초기 DB 연결
    await _snsDbHelper.connect(); // SNS DB 연결
    await _loadUploadedTravels(); // 업로드된 여행 목록 불러오기
  }

  @override
  void dispose() {
    _initdbHelper.close(); // 초기 DB 연결 종료
    _snsDbHelper.close(); // SNS DB 연결 종료
    super.dispose();
  }

  /// 업로드된 여행 데이터 로드
  Future<void> _loadUploadedTravels() async {
    final travels =
        await _snsDbHelper.getAllUploadedTravels(widget.userId); // SNS 데이터 로드
    setState(() {
      _uploadedTravels.clear();
      _uploadedTravels.addAll(travels);
    });
  }

  Future<void> _toggleLike(int snsId, bool isLiked) async {
    if (isLiked) {
      await _snsDbHelper.unlikeTravel(snsId, widget.userId);
    } else {
      await _snsDbHelper.likeTravel(snsId, widget.userId);
    }
    await _loadUploadedTravels();
  }

  /// 날짜 포맷 함수
  String _formatDate(String dateString) {
    final DateTime date = DateTime.parse(dateString);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 업로드 가능한 여행 목록 표시
  Future<void> _showUploadTravelModal() async {
    final travels = await _initdbHelper
        .getFinalizedTravels(widget.userId); // 최종 저장된 여행 가져오기

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '여행 업로드',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: travels.length,
                itemBuilder: (context, index) {
                  final travel = travels[index];
                  return ListTile(
                    title: Text(
                      travel['name'], // 여행 이름
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${travel['country']} | ${_formatDate(travel['start_date'])} ~ ${_formatDate(travel['end_date'])}', // 여행 국가 및 포맷된 날짜
                    ),
                    onTap: () async {
                      // 선택된 여행을 SNS에 업로드
                      await _initdbHelper
                          .markAsUploadedToSNS(travel['id']); // SNS 업로드 상태 업데이트
                      // SNS 업로드 처리
                      await _snsDbHelper.uploadTravelToSns(
                        travelId: travel['id'],
                        travelName: travel['name'],
                        travelCountry: travel['country'],
                        startDate: travel['start_date'],
                        endDate: travel['end_date'],
                        username: travel['username'],
                        userId: widget.userId, // 현재 사용자 ID를 추가
                      );
                      Navigator.pop(context); // Modal 창 닫기
                      await _loadUploadedTravels(); // 업로드된 데이터 다시 로드
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SNS Page',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: _uploadedTravels.isEmpty
          ? const Center(
              child: Text(
                '업로드된 여행이 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _uploadedTravels.length,
              itemBuilder: (context, index) {
                final travel = _uploadedTravels[index];
                final int snsId = travel['sns_id'] ?? 0; // sns_id를 가져옴
                final int travelId = travel['travel_id'] ?? 0; // null인 경우 기본값 0
                final String travelName = travel['travel_name'] ?? '이름 없음';
                final String travelCountry =
                    travel['travel_country'] ?? '국가 정보 없음';
                final String startDate = _formatDate(travel['start_date']);
                final String endDate = _formatDate(travel['end_date']);
                final String username = travel['username'] ?? '작성자 정보 없음';
                final int totalLikes = travel['total_likes'] ?? 0; // 좋아요 수
                final bool likedByUser =
                    travel['liked_by_user'] ?? false; // 좋아요 상태
                final int uploaderId = travel['user_id'] ?? 0; // 여행 작성자 ID

                // 자신의 여행인지 확인
                final bool isOwnTravel = uploaderId == widget.userId;

                return GestureDetector(
                  onTap: travelId > 0
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewMainPage(travelId: travelId),
                            ),
                          );
                        }
                      : null, // travelId가 없으면 아무 작업도 하지 않음
                  child: Card(
                    color: isOwnTravel ? Colors.yellow[100] : Colors.white,
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        travelName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$travelCountry | $startDate ~ $endDate'),
                          Text('작성자: $username'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              likedByUser
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: likedByUser ? Colors.red : null,
                            ),
                            onPressed: () async {
                              // 좋아요 토글 기능 추가
                              if (likedByUser) {
                                await _snsDbHelper.unlikeTravel(
                                    snsId, widget.userId);
                              } else {
                                await _snsDbHelper.likeTravel(
                                    snsId, widget.userId);
                              }
                              await _loadUploadedTravels(); // 상태 갱신
                            },
                          ),
                          Text('$totalLikes'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadTravelModal,
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      bottomNavigationBar: buildInitialBottomNavigationBar(
          context, 1, widget.userId), // 현재 Index는 2
    );
  }
}
