import 'package:flutter/material.dart';
import 'package:traveltree/widgets/NavigationHelper.dart';
import 'package:traveltree/page/ExpenseManagementPage.dart';
import 'package:traveltree/page/ScheduleManagementPage.dart'; // 일정관리 페이지 임포트

class SubFeaturePage extends StatelessWidget {
  const SubFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sub Feature Page')),
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
                    builder: (context) => const ExpenseManagementPage(),
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
                    builder: (context) => const ScheduleManagementPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildFeatureButton(
              context,
              label: '사진',
              onPressed: () {
                // 사진 페이지 이동 구현 예정
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, 1),
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
