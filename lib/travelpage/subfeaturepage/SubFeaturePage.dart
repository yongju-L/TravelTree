import 'package:flutter/material.dart';
import 'package:traveltree/travelpage/subfeaturepage/PhotoPage.dart';
import 'package:traveltree/widgets/TravelNavigation.dart';
import 'package:traveltree/travelpage/subfeaturepage/ExpenseManagementPage.dart';
import 'package:traveltree/travelpage/subfeaturepage/ScheduleManagementPage.dart';

class SubFeaturePage extends StatelessWidget {
  final int travelId; // travelId만 받도록 수정
  final int userId;

  const SubFeaturePage({
    super.key,
    required this.travelId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sub Features for Travel ID: $travelId'), // travelId 출력
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFeatureButton(
              context,
              label: '경비관리',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExpenseManagementPage(
                        travelId: travelId), // travelId 전달
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildFeatureButton(
              context,
              label: '일정관리',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleManagementPage(
                        travelId: travelId), // travelId 전달
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
                    builder: (context) => PhotoPage(travelId: travelId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        1,
        travelId,
        userId,
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
