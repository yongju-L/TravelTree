import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SnapToRoadsService {
  final String apiKey =
      'AIzaSyDNJWIYY-Jtu8OCeal_EPOL2AaYeeJucvQ'; // 생성한 API Key로 교체하세요.

  Future<List<LatLng>> snapToRoads(List<LatLng> path) async {
    final pathString =
        path.map((e) => '${e.latitude},${e.longitude}').join('|');
    final url = Uri.parse(
        'https://roads.googleapis.com/v1/snapToRoads?path=$pathString&key=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['snappedPoints'] as List)
          .map((point) => LatLng(
              point['location']['latitude'], point['location']['longitude']))
          .toList();
    } else {
      throw Exception('Failed to snap to roads');
    }
  }
}
