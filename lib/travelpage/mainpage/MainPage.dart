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
  final PathpointDatabaseHelper _dbHelper = PathpointDatabaseHelper();
  final TransportationDatabaseHelper _trandbHelper =
      TransportationDatabaseHelper();

  bool _isLoading = true;
  Set<Polyline> _polylines = {};
  List<LatLng> _pathCoordinates = [];
  bool _hasInitializedPosition = false;
  bool _isDisposed = false; // dispose 상태를 추적

  final Map<String, dynamic> _transportationData = {
    'Walking': {'distance': 0.0, 'duration': 0},
    'Driving': {'distance': 0.0, 'duration': 0},
    'Public Transport': {'distance': 0.0, 'duration': 0},
  };

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _initializeLocation();
    _locationTracking.onTransportUpdate = _updateTransportData;
  }

  Future<void> _loadSavedPath() async {
    final pathData = await _dbHelper.getPathPoints(widget.travelId);
    setState(() {
      _pathCoordinates = pathData
          .map((point) => LatLng(point['latitude'], point['longitude']))
          .toList();
      _polylines = {
        Polyline(
          polylineId: const PolylineId('path'),
          points: _pathCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      };
      _isLoading = false;
    });
  }

  void _initializeTracking() {
    _locationTracking.initializeTracking((controller) {});
    Geolocator.getPositionStream().listen((position) async {
      LatLng currentPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        _pathCoordinates.add(currentPosition);
        _polylines = {
          Polyline(
            polylineId: const PolylineId('path'),
            points: _pathCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        };
      });

      // DB에 경로 저장
      await _dbHelper.insertPathPoint(
        travelId: widget.travelId,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    });
  }

  Future<void> _initializeDatabase() async {
    await _trandbHelper.connect();
    await _dbHelper.connect();
    await _loadSavedPath();
    await _loadTransportationData();
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
    await _locationService.requestLocationPermission(context);

    _locationTracking.initializeTracking((controller) {
      if (!mounted) return;
      setState(() {});
    });

    try {
      Position position = await _locationService.getCurrentPosition();
      if (_isDisposed) return;
      _locationTracking.addPath(LatLng(position.latitude, position.longitude));

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasInitializedPosition = true;
      });
    } catch (error) {
      if (_isDisposed) return;
      print("위치 가져오기 실패: $error");
      _showErrorDialog();
    }
  }

  Future<void> _updateTransportData(
      String mode, double distance, int duration) async {
    if (mode == 'Unknown') return; // Unknown 데이터는 저장하지 않음

    if (!mounted) return;

    setState(() {
      if (!_transportationData.containsKey(mode)) {
        _transportationData[mode] = {'distance': 0.0, 'duration': 0};
      }

      _transportationData[mode]['distance'] =
          (_transportationData[mode]['distance'] as double) + distance;
      _transportationData[mode]['duration'] =
          (_transportationData[mode]['duration'] as int) + duration;
    });

    // DB에 데이터 저장
    await _trandbHelper.upsertTransportationData(
      travelId: widget.travelId,
      mode: mode,
      distance: _transportationData[mode]['distance'] as double,
      duration: _transportationData[mode]['duration'] as int,
    );
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
                  context, widget.travelId); // travelId만 전달
            },
          ),
        ],
      ),
      body: _isLoading || !_hasInitializedPosition
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _locationTracking.onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _pathCoordinates.isNotEmpty
                        ? _pathCoordinates.first
                        : _locationTracking
                            .currentPosition, // 데이터베이스의 첫 좌표 또는 현재 위치
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  polylines: _polylines, // 데이터베이스에서 불러온 경로
                ),
                StreamBuilder<Set<Polyline>>(
                  stream: _locationTracking.polylinesStream,
                  builder: (context, snapshot) {
                    // Polyline 추가: 실시간 데이터 + 데이터베이스 데이터 결합
                    final livePolylines = snapshot.data ?? {};
                    final combinedPolylines = Set<Polyline>.of(_polylines)
                      ..addAll(livePolylines);

                    return GoogleMap(
                      onMapCreated: _locationTracking.onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _locationTracking.currentPosition,
                        zoom: 15,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      polylines: combinedPolylines, // 결합된 Polyline
                    );
                  },
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
    super.dispose();
  }
}
