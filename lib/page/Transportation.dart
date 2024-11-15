import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Geolocator 추가
import 'package:traveltree/services/SnapToRoadsService.dart';
import 'package:traveltree/services/TransitService.dart';

class Transportation extends StatefulWidget {
  @override
  _TransportationState createState() => _TransportationState();
}

class _TransportationState extends State<Transportation> {
  final FlutterActivityRecognition _activityRecognition =
      FlutterActivityRecognition.instance;
  final SnapToRoadsService _snapToRoadsService = SnapToRoadsService();
  final TransitService _transitService = TransitService();

  final Map<String, double> _activityStats = {
    '도보': 0,
    '운전': 0,
    '자전거': 0,
    '버스': 0,
    '지하철': 0,
  };

  List<LatLng> _gpsData = []; // GPS 데이터를 저장할 리스트

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _startActivityTracking();
    _processGpsData(); // GPS 데이터 처리
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스가 비활성화되었습니다.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다.');
    }
  }

  void _startActivityTracking() {
    _activityRecognition.activityStream.listen((Activity activity) {
      setState(() {
        String type = activity.type.toString();

        if (type == 'IN_VEHICLE') {
          _activityStats['운전'] = (_activityStats['운전'] ?? 0) + 1;
        } else if (type == 'ON_BICYCLE') {
          _activityStats['자전거'] = (_activityStats['자전거'] ?? 0) + 1;
        } else if (type == 'WALKING') {
          _activityStats['도보'] = (_activityStats['도보'] ?? 0) + 1;
        }
      });
    });
  }

  Future<void> _processGpsData() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 새 위치 추가
      _gpsData.add(LatLng(position.latitude, position.longitude));

      // Snap to Roads와 Transit API 호출
      List<LatLng> snappedPoints =
          await _snapToRoadsService.snapToRoads(_gpsData);
      List<String> transitModes = await _transitService.getTransitModes(
          snappedPoints.first, snappedPoints.last);

      for (var mode in transitModes) {
        setState(() {
          if (mode == 'BUS') {
            _activityStats['버스'] = (_activityStats['버스'] ?? 0) + 1;
          } else if (mode == 'SUBWAY') {
            _activityStats['지하철'] = (_activityStats['지하철'] ?? 0) + 1;
          }
        });
      }

      print('Updated Stats: $_activityStats'); // 디버깅용 출력
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이동수단 통계')),
      body: ListView.builder(
        itemCount: _activityStats.length,
        itemBuilder: (context, index) {
          String type = _activityStats.keys.elementAt(index);
          double value = _activityStats[type]!;

          return ListTile(
            leading: Icon(
              type == '도보'
                  ? Icons.directions_walk
                  : type == '운전'
                      ? Icons.directions_car
                      : type == '자전거'
                          ? Icons.directions_bike
                          : type == '버스'
                              ? Icons.directions_bus
                              : Icons.subway, // 지하철 아이콘
            ),
            title: Text(type),
            subtitle: Text('${value.toStringAsFixed(2)} km'),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
