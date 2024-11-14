import 'package:flutter/material.dart';
import 'package:traveltree/page/Transportation.dart';

void showTransportationModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const FractionallySizedBox(
      heightFactor: 0.4,
      child: Transportation(),
    ),
  );
}
