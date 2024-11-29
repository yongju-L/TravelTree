import 'package:flutter/material.dart';
import 'package:traveltree/travelpage/mainpage/TransportationPage.dart';

class TransportationModal {
  static void showTransportationModal(BuildContext context, int travelId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TransportationPage(travelId: travelId),
      backgroundColor: Colors.transparent,
    );
  }
}
