import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:traveltree/services/LocationService.dart';
import 'package:traveltree/services/LocationTracking.dart';
import 'package:traveltree/widgets/NavigationHelper.dart';
import 'package:traveltree/widgets/TransportationModal.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final LocationTracking _locationTracking = LocationTracking();
  final LocationService _locationService = LocationService();

  bool _isLoading = true;
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
    _initializeLocation();
    _locationTracking.onTransportUpdate = _updateTransportData;
  }

  Future<void> _initializeLocation() async {
    await _locationService.requestLocationPermission(context);

    _locationTracking.initializeTracking((controller) {
      if (!mounted) return; // dispose 상태 확인
      setState(() {});
    });

    try {
      Position position = await _locationService.getCurrentPosition();
      if (_isDisposed) return; // dispose 상태 확인
      _locationTracking.addPath(LatLng(position.latitude, position.longitude));

      if (!mounted) return; // dispose 상태 확인
      setState(() {
        _isLoading = false;
        _hasInitializedPosition = true;
      });
    } catch (error) {
      if (_isDisposed) return; // dispose 상태 확인
      print("위치 가져오기 실패: $error");
      _showErrorDialog();
    }
  }

  void _updateTransportData(String mode, double distance, int duration) {
    if (mode == 'Unknown') {
      // Unknown 데이터는 저장하지 않음
      return;
    }

    if (!mounted) return; // dispose 상태 확인
    setState(() {
      if (!_transportationData.containsKey(mode)) {
        _transportationData[mode] = {'distance': 0.0, 'duration': 0};
      }

      _transportationData[mode]!['distance'] += distance;
      _transportationData[mode]!['duration'] += duration;
    });
  }

  void _showErrorDialog() {
    if (!mounted) return; // dispose 상태 확인
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
        title: const Text('Timeline Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car),
            onPressed: () {
              TransportationModal.showTransportationModal(
                  context, _transportationData);
            },
          ),
        ],
      ),
      body: _isLoading || !_hasInitializedPosition
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<Set<Polyline>>(
              stream: _locationTracking.polylinesStream,
              builder: (context, snapshot) {
                return GoogleMap(
                  onMapCreated: _locationTracking.onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _locationTracking.currentPosition,
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  polylines: snapshot.data ?? {},
                );
              },
            ),
      bottomNavigationBar: buildBottomNavigationBar(context, 0),
    );
  }

  @override
  void dispose() {
    _isDisposed = true; // dispose 상태를 true로 설정
    _locationTracking.dispose();
    super.dispose();
  }
}
