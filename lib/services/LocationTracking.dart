import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationTracking {
  final _polylinesController = StreamController<Set<Polyline>>.broadcast();
  Stream<Set<Polyline>> get polylinesStream => _polylinesController.stream;

  final List<LatLng> _pathCoordinates = [];
  GoogleMapController? _mapController; // 지도 컨트롤러

  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194), // 기본 위치
    zoom: 12,
  );

  void initializeTracking(void Function(GoogleMapController) onMapReady) {
    Geolocator.getPositionStream().listen((position) {
      _addPath(LatLng(position.latitude, position.longitude));

      // 위치 변경 시 지도의 카메라 업데이트
      if (_mapController != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    });
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller; // 컨트롤러 초기화
  }

  void _addPath(LatLng position) {
    _pathCoordinates.add(position);
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
    _polylinesController.close();
  }
}
