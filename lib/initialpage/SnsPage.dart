import 'package:flutter/material.dart';
import 'package:traveltree/helpers/InitialDatabaseHelper.dart';
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
  final InitialDatabaseHelper _initdbHelper = InitialDatabaseHelper(); // DB 헬퍼

  @override
  void initState() {
    super.initState();
    _initdbHelper.connect(); // DB 연결
  }

  @override
  void dispose() {
    _initdbHelper.close(); // DB 연결 해제
    super.dispose();
  }

  /// 날짜 포맷 함수
  String _formatDate(String dateString) {
    final DateTime date = DateTime.parse(dateString);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _showUploadTravelModal() async {
    final travels = await _initdbHelper
        .getFinalizedTravels(widget.userId); // 최종 저장된 여행 불러오기

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 제목
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
                      setState(() {
                        _uploadedTravels.add(travel); // 업로드된 여행을 리스트에 추가
                      });
                      Navigator.pop(context); // Modal 창 닫기
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
                return GestureDetector(
                  onTap: () {
                    // 여행 클릭 시 ViewMainPage로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ViewMainPage(travelId: travel['id']),
                      ),
                    );
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 여행 정보
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                travel['name'], // 여행 이름
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${travel['country']} | ${_formatDate(travel['start_date'])} ~ ${_formatDate(travel['end_date'])}', // 여행 국가 및 포맷된 날짜
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 샘플 이미지 또는 여행 이미지
                        Container(
                          height: 200,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(15),
                            ),
                            image: DecorationImage(
                              image: AssetImage('assets/sample_travel.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
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
          context, 2, widget.userId), // 현재 Index는 2
    );
  }
}
