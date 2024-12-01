import 'package:flutter/material.dart';
import 'package:traveltree/viewpages/ViewMainPage.dart';
import 'package:traveltree/viewpages/ViewSubFeaturePage.dart';

void navigateToPage(BuildContext context, int index, {required int travelId}) {
  Widget page;
  switch (index) {
    case 0:
      // ViewMainPage에 travelId만 전달
      page = ViewMainPage(travelId: travelId);
      break;
    case 1:
      // ViewSubFeaturePage에 travelId만 전달
      page = ViewSubFeaturePage(travelId: travelId);
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

BottomNavigationBar buildViewBottomNavigationBar(
    BuildContext context, int currentIndex, int travelId) {
  return BottomNavigationBar(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.grey,
    iconSize: 30,
    currentIndex: currentIndex,
    // travelId만 전달
    onTap: (index) => navigateToPage(context, index, travelId: travelId),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Main'),
      BottomNavigationBarItem(
          icon: Icon(Icons.featured_play_list), label: 'Features'),
    ],
  );
}
