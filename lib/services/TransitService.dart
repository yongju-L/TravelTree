import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TransitService {
  final String apiKey =
      'AIzaSyDNJWIYY-Jtu8OCeal_EPOL2AaYeeJucvQ'; // Google API Key

  Future<List<String>> getTransitModes(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=transit&key=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['routes'][0]['legs'][0]['steps'] as List)
          .where((step) => step['travel_mode'] == 'TRANSIT')
          .map((step) =>
              step['transit_details']['line']['vehicle']['type'] as String)
          .toList();
    } else {
      throw Exception('Failed to get transit modes');
    }
  }
}
