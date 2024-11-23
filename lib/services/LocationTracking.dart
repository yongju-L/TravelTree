import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationTracking {
  final _polylinesController = StreamController<Set<Polyline>>.broadcast();
  Stream<Set<Polyline>> get polylinesStream => _polylinesController.stream;

  final List<LatLng> _pathCoordinates = [];
  LatLng? _lastKnownPosition;
  DateTime? _lastTimestamp;

  LatLng get currentPosition =>
      _lastKnownPosition ?? const LatLng(0, 0); // 초기 값은 0,0 (빈 위치)

  Function(String, double, int)? onTransportUpdate;

  void onMapCreated(GoogleMapController controller) {}

  void initializeTracking(void Function(GoogleMapController) onMapReady) {
    Geolocator.getPositionStream().listen((position) {
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

        String mode = _determineTransportMode(distance, duration);
        onTransportUpdate?.call(mode, distance / 1000, duration);

        _lastTimestamp = now;
        addPath(currentLatLng);
      } else {
        _lastKnownPosition = LatLng(position.latitude, position.longitude);
        _lastTimestamp = DateTime.now();
      }
    });
  }

  String _determineTransportMode(double distance, int duration) {
    final speed = distance / (duration == 0 ? 1 : duration); // m/s
    if (speed < 1.4) {
      return 'Walking';
    } else if (speed < 6.0) {
      return 'Public Transport';
    } else {
      return 'Driving';
    }
  }

  void addPath(LatLng position) {
    _pathCoordinates.add(position);
    _lastKnownPosition = position;
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
