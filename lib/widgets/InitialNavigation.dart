import 'package:flutter/material.dart';
import 'package:traveltree/initialpage/InitialPage.dart';
import 'package:traveltree/initialpage/LankingPage.dart';
import 'package:traveltree/initialpage/SnsPage.dart';

void navigateToInitialPage(BuildContext context, int index, int userId) {
  Widget page;
  switch (index) {
    case 0:
      page = InitialPage(userId: userId); // userId 전달
      break;
    case 1:
      page = SnsPage(userId: userId); // SnsPage가 두 번째로 이동
      break;
    case 2:
      page = LankingPage(userId: userId); // LankingPage가 세 번째로 이동
      break;
    default:
      return;
  }
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var offsetAnimation = animation.drive(
          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeInOut)),
        );
        return SlideTransition(position: offsetAnimation, child: child);
      },
    ),
  );
}

BottomNavigationBar buildInitialBottomNavigationBar(
    BuildContext context, int currentIndex, int userId) {
  return BottomNavigationBar(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.grey,
    iconSize: 30,
    currentIndex: currentIndex, // 현재 페이지의 인덱스 전달
    onTap: (index) => navigateToInitialPage(context, index, userId),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Initial'),
      BottomNavigationBarItem(
          icon: Icon(Icons.group), label: 'SNS'), // SNS가 두 번째
      BottomNavigationBarItem(
          icon: Icon(Icons.star), label: 'Lanking'), // Lanking이 세 번째
    ],
  );
}
