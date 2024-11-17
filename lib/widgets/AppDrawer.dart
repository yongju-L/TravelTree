import 'package:flutter/material.dart';
import 'package:traveltree/page/subfeaturepage/ExpenseManagementPage.dart';
import 'package:traveltree/page/subfeaturepage/ScheduleManagementPage.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              '메뉴',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('경비관리'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExpenseManagementPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('일정관리'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ScheduleManagementPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('사진'),
            onTap: () {
              // 사진 페이지로 이동 구현 예정
            },
          ),
        ],
      ),
    );
  }
}
