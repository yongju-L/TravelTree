import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:traveltree/helpers/PathpointDatabaseHelper.dart';
import 'package:traveltree/helpers/TransportationDatabaseHelper.dart';
import 'package:traveltree/services/LocationService.dart';
import 'package:traveltree/services/LocationTracking.dart';
import 'package:traveltree/widgets/TravelNavigation.dart';
import 'package:traveltree/widgets/TransportationModal.dart';

class MainPage extends StatefulWidget {
  final int travelId; // 여행 고유 ID 추가

  const MainPage({
    super.key,
    required this.travelId, // travelId를 필수 매개변수로 추가
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final LocationTracking _locationTracking = LocationTracking();
  final LocationService _locationService = LocationService();
  final PathpointDatabaseHelper _pathDbHelper = PathpointDatabaseHelper();
  final TransportationDatabaseHelper _trandbHelper =
      TransportationDatabaseHelper();

  bool _isLoading = true;
  bool _hasInitializedPosition = false;
  bool _isDisposed = false; // dispose 상태를 추적
  bool _isTrackingActive = false; // Start 버튼 상태를 나타내는 변수

  final Map<String, dynamic> _transportationData = {
    'Walking': {'distance': 0.0, 'duration': 0},
    'Driving': {'distance': 0.0, 'duration': 0},
    'Public Transport': {'distance': 0.0, 'duration': 0},
  };

  LatLng _initialPosition = const LatLng(37.7749, -122.4194); // 기본값: 샌프란시스코
  Set<Polyline> _savedPolylines = {}; // 저장된 polyline 데이터를 보관

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final hasPermission =
        await _locationService.requestLocationPermission(context);
    if (!hasPermission) {
      return; // 권한이 없으면 초기화 중단
    }

    await _initializeMainPage();
  }

  Future<void> _initializeMainPage() async {
    await _setInitialPosition(); // 초기 위치 설정
    await _loadSavedPolylines(); // 저장된 Polyline 불러오기
    await _initializeLocation();
    await _initializeTranDatabase(); // 교통 데이터 초기화
    if (_isTrackingActive) {
      _initializeTracking(); // 실시간 경로 그리기 시작
    }
  }

  Future<void> _setInitialPosition() async {
    try {
      Position position = await _locationService.getCurrentPosition();
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _hasInitializedPosition = true; // 위치 초기화 완료
      });
    } catch (e) {
      print('초기 위치를 가져오는 데 실패했습니다: $e');
      // 초기 위치를 가져오는 데 실패하면 기본값 유지
      setState(() {
        _hasInitializedPosition = true; // 기본 위치로 초기화 완료
      });
    }
  }

  Future<void> _loadSavedPolylines() async {
    try {
      await _pathDbHelper.connect();
      final savedPolylinePoints =
          await _pathDbHelper.getPolyline(widget.travelId);

      if (savedPolylinePoints.isNotEmpty) {
        setState(() {
          _savedPolylines.add(Polyline(
            polylineId: const PolylineId('savedPath'),
            points: savedPolylinePoints,
            color: Colors.blue,
            width: 5,
          ));
        });
      }
    } catch (e) {
      print('Error loading saved polylines: $e');
    }
  }

  Future<void> _initializeTranDatabase() async {
    await _trandbHelper.connect();
    await _loadTransportationData();
  }

  Future<void> _savePath() async {
    if (_isTrackingActive) {
      // 현재 Polyline과 이전에 저장된 Polyline 병합
      List<LatLng> combinedPath = [
        ..._savedPolylines.expand((polyline) => polyline.points), // 이전 Polyline
        ..._locationTracking.currentPath // 현재 Polyline
      ];

      // 병합된 Polyline 저장
      await _pathDbHelper.upsertPolyline(widget.travelId, combinedPath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Polyline 경로가 저장되었습니다.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Start 버튼을 누르고 저장해주세요.")),
      );
    }
  }

  Future<void> _loadTransportationData() async {
    final data = await _trandbHelper.getTransportationData(widget.travelId);
    setState(() {
      for (var entry in data) {
        _transportationData[entry['mode']] = {
          'distance': entry['distance'] ?? 0.0,
          'duration': entry['duration'] ?? 0,
        };
      }
    });
  }

  Future<void> _initializeLocation() async {
    Position position = await _locationService.getCurrentPosition();

    try {
      if (_isDisposed) return;

      if (_isTrackingActive) {
        // Polyline 추가는 Start 버튼이 눌린 경우에만
        _locationTracking
            .addPath(LatLng(position.latitude, position.longitude));
      }

      setState(() {
        _isLoading = false;
        _hasInitializedPosition = true;
      });
    } catch (error) {
      if (_isDisposed) return;
      print("위치 가져오기 실패: $error");
    }
  }

  void _initializeTracking() {
    if (!_isTrackingActive) return;

    _locationTracking.initializeTracking((controller) {
      setState(() {}); // 실시간 경로 반영
    });
    _locationTracking.initializePathDatabase();
    _locationTracking.onTransportUpdate = _updateTransportData;
  }

  Future<void> _updateTransportData(
      String mode, double distance, int duration) async {
    if (!_isTrackingActive || mode == 'Unknown') {
      return; // Start 버튼이 눌리지 않았거나 Unknown이면 무시
    }

    setState(() {
      if (!_transportationData.containsKey(mode)) {
        _transportationData[mode] = {'distance': 0.0, 'duration': 0};
      }
      _transportationData[mode]!['distance'] += distance;
      _transportationData[mode]!['duration'] += duration;
    });

    // DB에 데이터 저장
    await _trandbHelper.upsertTransportationData(
      travelId: widget.travelId,
      mode: mode,
      distance: _transportationData[mode]!['distance'],
      duration: _transportationData[mode]!['duration'],
    );
  }

  void _toggleTracking() async {
    if (_isTrackingActive) {
      // 추적 중지 및 저장
      await _savePath();
      setState(() {
        _isTrackingActive = false;
      });
      _locationTracking.dispose();
    } else {
      // 추적 시작
      setState(() {
        _isTrackingActive = true;
      });
      _initializeTracking();
    }
  }

  void _showErrorDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 가져오기 실패'),
        content: const Text('현재 위치를 가져오는 데 실패했습니다. 다시 시도해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TravelTree'),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car),
            onPressed: () {
              TransportationModal.showTransportationModal(
                  context, widget.travelId); // travelId 전달
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading || !_hasInitializedPosition
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : StreamBuilder<Set<Polyline>>(
                  stream: _locationTracking.polylinesStream,
                  builder: (context, snapshot) {
                    final polylines = {
                      if (snapshot.hasData) ...snapshot.data!,
                      ..._savedPolylines,
                    };

                    return GoogleMap(
                      onMapCreated: _locationTracking.onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _initialPosition,
                        zoom: 15,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      polylines: polylines,
                    );
                  },
                ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _toggleTracking,
              backgroundColor: _isTrackingActive ? Colors.red : Colors.green,
              child: Text(
                _isTrackingActive ? 'Stop' : 'Start',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        0,
        widget.travelId, // travelId 전달
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _locationTracking.dispose();
    _pathDbHelper.close();
    super.dispose();
  }
}
