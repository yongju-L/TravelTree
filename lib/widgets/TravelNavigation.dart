import 'package:flutter/material.dart';
import 'package:traveltree/travelpage/mainpage/MainPage.dart';
import 'package:traveltree/travelpage/subfeaturepage/SubFeaturePage.dart';

void navigateToPage(
  BuildContext context,
  int index, {
  required int travelId,
  required int userId, // userId 추가
}) {
  Widget page;
  switch (index) {
    case 0:
      // MainPage에 travelId와 userId 전달
      page = MainPage(travelId: travelId, userId: userId);
      break;
    case 1:
      // SubFeaturePage에 travelId와 userId 전달
      page = SubFeaturePage(travelId: travelId, userId: userId);
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
    BuildContext context, int currentIndex, int travelId, int userId) {
  return BottomNavigationBar(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.grey,
    iconSize: 30,
    currentIndex: currentIndex,
    onTap: (index) => navigateToPage(
      context,
      index,
      travelId: travelId, // travelId 전달
      userId: userId, // userId 추가로 전달
    ),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Main'),
      BottomNavigationBarItem(
          icon: Icon(Icons.featured_play_list), label: 'Features'),
    ],
  );
}
