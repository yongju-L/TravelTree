import 'package:flutter/material.dart';
import 'package:traveltree/page/Transportation.dart';

void showTransportationModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.5,
      child: Transportation(),
    ),
  );
}
