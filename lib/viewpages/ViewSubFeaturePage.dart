import 'package:flutter/material.dart';
import 'package:traveltree/viewpages/ViewExpenseManagementPage.dart';
import 'package:traveltree/viewpages/ViewPhotoPage.dart';
import 'package:traveltree/viewpages/ViewScheduleManagementPage.dart';
import 'package:traveltree/widgets/ViewNavigation.dart';

class ViewSubFeaturePage extends StatelessWidget {
  final int travelId; // travelId 추가

  const ViewSubFeaturePage({
    super.key,
    required this.travelId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Features for Travel ID: $travelId'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFeatureButton(
              context,
              label: '경비 보기',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewExpenseManagementPage(travelId: travelId),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildFeatureButton(
              context,
              label: '일정 보기',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewScheduleManagementPage(travelId: travelId),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildFeatureButton(
              context,
              label: '사진 보기',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewPhotoPage(travelId: travelId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildViewBottomNavigationBar(
        context,
        0,
        travelId, // travelId 전달
      ),
    );
  }

  Widget _buildFeatureButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
