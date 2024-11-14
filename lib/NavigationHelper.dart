import 'package:flutter/material.dart';
import 'package:traveltree/page/MainPage.dart';
import 'package:traveltree/page/Page1.dart';
import 'package:traveltree/page/Page2.dart';
import 'package:traveltree/page/Page3.dart';

void navigateToPage(BuildContext context, int index) {
  Widget page;
  switch (index) {
    case 0:
      page = const MainPage();
      break;
    case 1:
      page = const Page1();
      break;
    case 2:
      page = const Page2();
      break;
    case 3:
      page = const Page3();
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

BottomNavigationBar buildBottomNavigationBar(
    BuildContext context, int currentIndex) {
  return BottomNavigationBar(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.grey,
    iconSize: 30,
    currentIndex: currentIndex,
    onTap: (index) => navigateToPage(context, index),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'main'),
      BottomNavigationBarItem(icon: Icon(Icons.looks_one), label: '1'),
      BottomNavigationBarItem(icon: Icon(Icons.looks_two), label: '2'),
      BottomNavigationBarItem(icon: Icon(Icons.looks_3), label: '3'),
    ],
  );
}
