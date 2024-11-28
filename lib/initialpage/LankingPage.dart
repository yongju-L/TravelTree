import 'package:flutter/material.dart';
import 'package:traveltree/widgets/InitialNavigation.dart';

class LankingPage extends StatelessWidget {
  final int userId; // userId 추가

  const LankingPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('랭킹 페이지'),
      ),
      body: const Center(
        child: Text('랭킹 페이지 내용'),
      ),
      bottomNavigationBar:
          buildInitialBottomNavigationBar(context, 1, userId), // userId 전달
    );
  }
}
