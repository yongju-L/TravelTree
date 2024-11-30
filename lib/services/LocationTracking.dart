import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:traveltree/helpers/PathpointDatabaseHelper.dart';

class LocationTracking {
  final _polylinesController = StreamController<Set<Polyline>>.broadcast();
  Stream<Set<Polyline>> get polylinesStream => _polylinesController.stream;

  final List<LatLng> _pathCoordinates = [];
  LatLng? _lastKnownPosition;
  DateTime? _lastTimestamp;

  PathpointDatabaseHelper? _dbHelper;
  StreamSubscription<Position>? _positionStreamSubscription; // 스트림 구독 관리

  void initializePathDatabase() async {
    _dbHelper = PathpointDatabaseHelper();
    await _dbHelper!.connect();
  }

  Future<void> savePathToDatabase(int travelId) async {
    if (_pathCoordinates.isNotEmpty && _dbHelper != null) {
      await _dbHelper!.savePolyline(travelId, _pathCoordinates); // 비동기 작업 수행
    }
  }

  LatLng get currentPosition =>
      _lastKnownPosition ?? const LatLng(0, 0); // 초기 값은 0,0 (빈 위치)

  Function(String, double, int)? onTransportUpdate;

  final String _apiKey =
      "AIzaSyDNJWIYY-Jtu8OCeal_EPOL2AaYeeJucvQ"; // Google Maps API 키
  LatLng? _lastCheckedPosition; // 마지막 도로 확인 위치

  void onMapCreated(GoogleMapController controller) {}

  void initializeTracking(void Function(GoogleMapController) onMapReady) {
    // 기존 스트림 구독 취소
    _cancelPositionStream();

    // 새 스트림 구독 시작
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((position) async {
      if (_lastKnownPosition != null) {
        final currentLatLng = LatLng(position.latitude, position.longitude);
        final distance = Geolocator.distanceBetween(
          _lastKnownPosition!.latitude,
          _lastKnownPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        final now = DateTime.now();
        final duration = _lastTimestamp != null
            ? now.difference(_lastTimestamp!).inSeconds
            : 0;

        String mode =
            await _determineTransportMode(currentLatLng, distance, duration);
        onTransportUpdate?.call(mode, distance / 1000, duration);

        _lastTimestamp = now;
        addPath(currentLatLng);
      } else {
        _lastKnownPosition = LatLng(position.latitude, position.longitude);
        _lastTimestamp = DateTime.now();
      }
    });
  }

  void _cancelPositionStream() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel(); // 기존 스트림 구독 취소
      _positionStreamSubscription = null;
    }
  }

  Future<String> _determineTransportMode(
      LatLng currentLatLng, double distance, int duration) async {
    final speed = distance / (duration == 0 ? 1 : duration); // m/s

    if (speed < 2.0) {
      // 도보로 판단 (속도 2m/s 미만)
      return 'Walking';
    }

    if (speed > 50.0) {
      // 50m/s 초과 시 Unknown 반환
      return 'Unknown';
    }

    // Driving 여부 확인
    final isOnRoad = await _isOnRoad(currentLatLng);
    if (isOnRoad) {
      return 'Driving';
    }

    // Driving이 아니면 Public Transport로 분류
    return 'Public Transport';
  }

  Future<bool> _isOnRoad(LatLng latLng) async {
    // 이전 확인된 위치와 가까우면 기존 결과를 사용
    if (_lastCheckedPosition != null &&
        Geolocator.distanceBetween(
              _lastCheckedPosition!.latitude,
              _lastCheckedPosition!.longitude,
              latLng.latitude,
              latLng.longitude,
            ) <
            50) {
      return false; // 캐싱된 결과를 사용할 수도 있음
    }

    _lastCheckedPosition = latLng; // 새로운 위치 업데이트

    final url =
        "https://roads.googleapis.com/v1/nearestRoads?points=${latLng.latitude},${latLng.longitude}&key=$_apiKey";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['snappedPoints'] != null; // 도로 데이터가 있으면 true 반환
      }
    } catch (e) {
      print('Error checking road data: $e');
    }
    return false;
  }

  void addPath(LatLng position) {
    _pathCoordinates.add(position);
    if (_polylinesController.isClosed) {
      print('Cannot add events, StreamController is closed.');
      return;
    }
    _polylinesController.add({
      Polyline(
        polylineId: const PolylineId('path'),
        points: _pathCoordinates,
        color: Colors.blue,
        width: 5,
      ),
    });
  }

  void dispose() {
    if (!_polylinesController.isClosed) {
      _polylinesController.close();
    }
    _cancelPositionStream(); // 스트림 구독 취소
    _dbHelper?.close();
  }
}
