import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:traveltree/widgets/AppDrawer.dart';

class PhotoPage extends StatefulWidget {
  final int travelId;

  const PhotoPage({super.key, required this.travelId});

  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();

  // 앨범에서 사진 선택
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _photos.add(File(image.path));
        });
      }
    } catch (e) {
      // 예외 처리 (사용자가 권한을 거부하거나 문제가 발생했을 경우)
      print("Failed to pick image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Gallery'),
      ),
      drawer: AppDrawer(travelId: widget.travelId), // AppDrawer에 travelId 전달
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Add Photo from Gallery'),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                return Image.file(
                  _photos[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
