import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:traveltree/NavigationHelper.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GoogleMapController? _mapController;
  List<LatLng> _pathCoordinates = [];
  Set<Polyline> _polylines = {};
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && !await _showEnableLocationDialog()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 서비스가 활성화되지 않았습니다.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('위치 권한 요청 실패')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.')),
        );
        return;
      }

      _getCurrentLocation();
      _startTracking();
    } catch (e) {
      print("Error in _requestLocationPermission: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('위치 권한 요청 중 오류 발생: $e')),
      );
    }
  }

  Future<bool> _showEnableLocationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('위치 서비스 활성화'),
            content: const Text('위치 서비스가 비활성화되어 있습니다. 활성화하시겠습니까?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('거부')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('허용')),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
              LatLng(position.latitude, position.longitude), 15),
        );
      });
    } catch (e) {
      print("Error in _getCurrentLocation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('위치 정보를 가져오는 중 오류 발생: $e')),
      );
    }
  }

  void _startTracking() {
    try {
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        setState(() {
          LatLng newPosition = LatLng(position.latitude, position.longitude);
          _pathCoordinates.add(newPosition);
          _polylines = {
            Polyline(
              polylineId: const PolylineId("path"),
              color: Colors.blue,
              width: 5,
              points: _pathCoordinates,
            ),
          };
        });
      });
    } catch (e) {
      print("Error in _startTracking: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('위치 추적 중 오류 발생: $e')),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    try {
      _mapController = controller;
      if (_currentPosition != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            15,
          ),
        );
      } else {
        _getCurrentLocation();
      }
    } catch (e) {
      print("Error in _onMapCreated: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('맵 생성 중 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timeline Map')),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    _currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 12,
              ),
              polylines: _polylines,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
      bottomNavigationBar: buildBottomNavigationBar(context, 0),
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
