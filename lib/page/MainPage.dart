import 'package:flutter/material.dart';
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
  GoogleMapController? _mapController;
  final LocationTracking _locationTracking = LocationTracking();
  final LocationService _locationService =
      LocationService(); // LocationService 인스턴스 생성

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _locationService.requestLocationPermission(context); // 위치 권한 요청
    _locationTracking.initializeTracking((controller) {
      setState(() {
        _mapController = controller;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car),
            onPressed: () => showTransportationModal(context),
          ),
        ],
      ),
      body: StreamBuilder<Set<Polyline>>(
        stream: _locationTracking.polylinesStream,
        builder: (context, snapshot) {
          return GoogleMap(
            onMapCreated:
                _mapController == null ? _locationTracking.onMapCreated : null,
            initialCameraPosition: _locationTracking.initialPosition,
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
    _locationTracking.dispose();
    super.dispose();
  }
}
