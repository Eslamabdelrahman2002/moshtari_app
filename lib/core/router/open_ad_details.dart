// core/router/open_ad_details.dart
import 'package:flutter/material.dart';

const Map<int, String> categoryIdToSource = {
  1: 'car_ads',
  2: 'real_estate_ads',
  3: 'car_parts_ads',
};

void openAdDetails(
    BuildContext context, {
      required int id,
      int? categoryId,
      String? source,
    }) {
  final String resolvedSource =
  (source != null && source.isNotEmpty) ? source : (categoryIdToSource[categoryId ?? -1] ?? '');

  switch (resolvedSource) {
    case 'car_ads':
      Navigator.pushNamed(context, '/carDetailsScreen', arguments: id);
      break;
    case 'car_parts_ads':
      Navigator.pushNamed(context, '/carPartDetailsScreen', arguments: id);
      break;
    case 'real_estate_ads':
      Navigator.pushNamed(context, '/realEstateDetailsScreen', arguments: id);
      break;
    default:
      Navigator.pushNamed(context, '/genericAdDetails', arguments: id);
  }
}