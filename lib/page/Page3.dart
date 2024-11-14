import 'package:flutter/material.dart';
import 'package:traveltree/widgets/NavigationHelper.dart';

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page 3')),
      body: const Center(
          child: Text('이곳은 Page 3입니다.', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: buildBottomNavigationBar(context, 3),
    );
  }
}
