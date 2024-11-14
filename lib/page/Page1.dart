import 'package:flutter/material.dart';
import 'package:traveltree/NavigationHelper.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page 1')),
      body: const Center(
          child: Text('이곳은 Page 1입니다.', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: buildBottomNavigationBar(context, 1),
    );
  }
}
