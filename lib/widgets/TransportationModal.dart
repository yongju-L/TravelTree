import 'package:flutter/material.dart';
import 'package:traveltree/travelpage/mainpage/TransportationPage.dart';

class TransportationModal {
  static void showTransportationModal(
      BuildContext context, Map<String, dynamic> transportationData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          TransportationPage(transportationData: transportationData),
      backgroundColor: Colors.transparent,
    );
  }
}
