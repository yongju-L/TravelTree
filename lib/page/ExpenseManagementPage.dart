import 'package:flutter/material.dart';
import 'package:traveltree/widgets/AppDrawer.dart'; // Drawer 임포트

class ExpenseManagementPage extends StatelessWidget {
  const ExpenseManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('경비관리'),
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
      body: Center(child: const Text('경비관리 페이지 내용')),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                // 통계 페이지 이동 예정
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // 경비 추가 기능 예정
              },
            ),
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                // 현황 페이지 이동 예정
              },
            ),
          ],
        ),
      ),
    );
  }
}
