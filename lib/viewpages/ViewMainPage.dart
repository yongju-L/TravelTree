import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:traveltree/helpers/PathpointDatabaseHelper.dart';
import 'package:traveltree/widgets/ViewNavigation.dart';
import 'ViewTransportationPage.dart';
import 'dart:io';

class ViewMainPage extends StatefulWidget {
  final int travelId;

  const ViewMainPage({Key? key, required this.travelId}) : super(key: key);

  @override
  _ViewMainPageState createState() => _ViewMainPageState();
}

class _ViewMainPageState extends State<ViewMainPage> {
  final PathpointDatabaseHelper _pathDbHelper = PathpointDatabaseHelper();

  Set<Polyline> _polylines = {};
  List<Marker> _markers = [];
  LatLng? _initialPosition; // 사용자 처음 위치를 저장
  bool _isLoading = true; // 로딩 상태
  bool _hasData = false; // 경로 데이터 존재 여부

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load polylines
    await _pathDbHelper.connect();
    final polylinePoints = await _pathDbHelper.getPolyline(widget.travelId);
    setState(() {
      _polylines = {
        if (polylinePoints.isNotEmpty)
          Polyline(
            polylineId: const PolylineId('savedRoute'),
            points: polylinePoints,
            color: Colors.blue,
            width: 5,
          ),
      };

      // 사용자 처음 위치를 Polyline의 첫 번째 포인트로 설정
      if (polylinePoints.isNotEmpty) {
        _initialPosition = polylinePoints.first;
        _hasData = true; // 데이터가 있음을 표시
      }
    });

    // Load markers
    final markers = await _pathDbHelper.getPins(widget.travelId);
    setState(() {
      _markers = markers.map((marker) {
        return Marker(
          markerId: MarkerId(marker['id'].toString()),
          position: LatLng(marker['latitude'], marker['longitude']),
          onTap: () => _showPhotos(marker['id']), // 핀 클릭 시 사진 보기
        );
      }).toList();
    });

    // 로딩 상태 종료
    setState(() {
      _isLoading = false;
    });
  }

  /// 핀에 저장된 사진 보기
  Future<void> _showPhotos(int pinId) async {
    try {
      final photos = await _pathDbHelper.getPhotos(pinId); // 핀에 저장된 사진 불러오기

      if (photos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이 핀에 저장된 사진이 없습니다.')),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        builder: (context) => ListView.builder(
          shrinkWrap: true,
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                File(photo['photoPath']), // 사진 경로에서 파일 로드
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      );
    } catch (e) {
      print('Error fetching photos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진을 불러오는 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Travel Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewTransportationPage(
                    travelId: widget.travelId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(), // 로딩 화면
            )
          : (!_hasData
              ? const Center(
                  child: Text(
                    '저장된 경로가 없습니다.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _initialPosition!,
                        zoom: 15,
                      ),
                      myLocationEnabled: false, // 읽기 전용이므로 위치 비활성화
                      markers: Set<Marker>.of(_markers),
                      polylines: _polylines,
                    ),
                  ],
                )),
      bottomNavigationBar: buildViewBottomNavigationBar(
        context,
        0,
        widget.travelId, // travelId 전달
      ),
    );
  }
}
