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
  Map<String, List<Map<String, dynamic>>> _photosByLocation =
      {}; // 장소별 사진 정렬 데이터
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

      Map<String, List<Map<String, dynamic>>> photosByLocation = {};

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
        final photoData = photos
            .map((photo) => {
                  'id': photo['id'],
                  'photoPath': photo['photoPath'],
                })
            .toList();

        // 장소별로 사진 정렬
        if (!photosByLocation.containsKey(place)) {
          photosByLocation[place] = [];
        }
        photosByLocation[place]!.addAll(photoData);
      }

      setState(() {
        _photosByLocation = photosByLocation;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading photos: $e');
    }
  }

  Future<void> _deletePhoto(
      int photoId, String photoPath, String location) async {
    try {
      // DB에서 사진 삭제
      await _dbHelper.deletePhoto(photoId);

      // 로컬 파일 삭제
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }

      // UI 갱신
      setState(() {
        _photosByLocation[location]
            ?.removeWhere((photo) => photo['id'] == photoId);
        if (_photosByLocation[location]?.isEmpty ?? true) {
          _photosByLocation.remove(location); // 장소에 사진이 없으면 제거
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진이 삭제되었습니다.')),
      );
    } catch (e) {
      print('Error deleting photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진 삭제 중 오류가 발생했습니다.')),
      );
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
              ? const Center(child: Text('불러올 사진이 없습니다.'))
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
                            final photo = photos[index];

                            return GestureDetector(
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("삭제 확인"),
                                    content: const Text("이 사진을 삭제하시겠습니까?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("취소"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deletePhoto(
                                            photo['id'],
                                            photo['photoPath'],
                                            location,
                                          );
                                        },
                                        child: const Text("삭제"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Image.file(
                                File(photo['photoPath']),
                                fit: BoxFit.cover,
                              ),
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
