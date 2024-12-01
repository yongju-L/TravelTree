import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:traveltree/helpers/PathpointDatabaseHelper.dart';
import 'package:traveltree/widgets/ViewNavigation.dart';
import 'ViewTransportationPage.dart';

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
        );
      }).toList();
    });

    // 로딩 상태 종료
    setState(() {
      _isLoading = false;
    });
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
