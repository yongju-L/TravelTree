import 'package:flutter/material.dart';
import 'package:traveltree/widgets/NavigationHelper.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page 2')),
      body: const Center(
          child: Text('이곳은 Page 2입니다.', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: buildBottomNavigationBar(context, 2),
    );
  }
}
