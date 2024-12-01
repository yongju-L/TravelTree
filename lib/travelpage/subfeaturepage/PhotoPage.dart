import 'package:flutter/material.dart';
import 'dart:io';
import 'package:traveltree/helpers/PathpointDatabaseHelper.dart';
import 'package:geocoding/geocoding.dart';
import 'package:traveltree/widgets/AppDrawer.dart';

class PhotoPage extends StatefulWidget {
  final int travelId;

  const PhotoPage({super.key, required this.travelId});

  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  final PathpointDatabaseHelper _dbHelper = PathpointDatabaseHelper();
  Map<String, List<File>> _photosByLocation = {}; // 장소별 사진 정렬 데이터
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      await _dbHelper.connect();
      final pins = await _dbHelper.getPins(widget.travelId);

      Map<String, List<File>> photosByLocation = {};

      for (var pin in pins) {
        final pinId = pin['id'];
        final latitude = pin['latitude'];
        final longitude = pin['longitude'];

        // 장소명 얻기 (역지오코딩)
        final placemarks = await placemarkFromCoordinates(latitude, longitude);
        final place = placemarks.isNotEmpty
            ? '${placemarks.first.country} ${placemarks.first.administrativeArea} ${placemarks.first.locality}'
            : 'Unknown Location';

        // 핀별 사진 가져오기
        final photos = await _dbHelper.getPhotos(pinId);
        final photoFiles =
            photos.map((photo) => File(photo['photoPath'])).toList();

        // 장소별로 사진 정렬
        if (!photosByLocation.containsKey(place)) {
          photosByLocation[place] = [];
        }
        photosByLocation[place]!.addAll(photoFiles);
      }

      setState(() {
        _photosByLocation = photosByLocation;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading photos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery'),
      ),
      drawer: AppDrawer(travelId: widget.travelId), // AppDrawer에 travelId 전달
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photosByLocation.isEmpty
              ? const Center(child: Text('No photos available.'))
              : ListView(
                  children: _photosByLocation.entries.map((entry) {
                    final location = entry.key;
                    final photos = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '-$location-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GridView.builder(
                          physics:
                              const NeverScrollableScrollPhysics(), // 스크롤 비활성화
                          shrinkWrap: true, // 부모 컨테이너 크기에 맞춤
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            return Image.file(
                              photos[index],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
    );
  }

  @override
  void dispose() {
    _dbHelper.close();
    super.dispose();
  }
}
