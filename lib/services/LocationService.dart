import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<void> requestLocationPermission(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showEnableLocationDialog(context);

      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar(context, '위치 권한 요청 실패');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(context, '위치 권한이 영구적으로 거부되었습니다.');
    }
  }

  void _showEnableLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 서비스 활성화'),
        content: const Text('위치 서비스가 비활성화되어 있습니다. 활성화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('거부'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('허용'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
