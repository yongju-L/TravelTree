import 'package:flutter/material.dart';
import 'package:traveltree/widgets/AppDrawer.dart'; // Drawer 임포트

class ScheduleManagementPage extends StatelessWidget {
  const ScheduleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정관리'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(), // AppDrawer 사용
      body: const Center(child: Text('일정관리 페이지 내용')),
    );
  }
}
