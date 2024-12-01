import 'package:flutter/material.dart';
import 'package:traveltree/travelpage/subfeaturepage/ExpenseManagementPage.dart';
import 'package:traveltree/travelpage/subfeaturepage/PhotoPage.dart';
import 'package:traveltree/travelpage/subfeaturepage/ScheduleManagementPage.dart';

class AppDrawer extends StatelessWidget {
  final int travelId; // travelId 추가

  const AppDrawer({super.key, required this.travelId});

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
                  builder: (context) => ExpenseManagementPage(
                    travelId: travelId, // travelId 전달
                  ),
                ),
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
                  builder: (context) => ScheduleManagementPage(
                    travelId: travelId, // travelId 전달
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('사진'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoPage(
                    travelId: travelId, // travelId 전달
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
