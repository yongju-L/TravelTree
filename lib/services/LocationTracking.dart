import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationTracking {
  final _polylinesController = StreamController<Set<Polyline>>.broadcast();
  Stream<Set<Polyline>> get polylinesStream => _polylinesController.stream;

  final List<LatLng> _pathCoordinates = [];
  GoogleMapController? _mapController;

  // 마지막 위치를 저장하는 변수
  LatLng? _lastKnownPosition;

  LatLng get currentPosition =>
      _lastKnownPosition ?? const LatLng(0, 0); // 초기 값은 0,0 (빈 위치)

  void initializeTracking(void Function(GoogleMapController) onMapReady) {
    Geolocator.getPositionStream().listen((position) {
      addPath(LatLng(position.latitude, position.longitude));

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
    _mapController = controller;
  }

  void addPath(LatLng position) {
    _pathCoordinates.add(position);
    _lastKnownPosition = position; // 마지막 위치 업데이트
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
