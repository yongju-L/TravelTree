import 'package:flutter/material.dart';
import 'package:traveltree/widgets/InitialNavigation.dart';

class SnsPage extends StatelessWidget {
  final int userId;

  const SnsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SNS Page')),
      body: const Center(child: Text('Welcome to SNS Page')),
      bottomNavigationBar:
          buildInitialBottomNavigationBar(context, 2, userId), // 현재 Index는 2
    );
  }
}
