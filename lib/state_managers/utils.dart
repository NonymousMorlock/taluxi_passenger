// taxi found data converter
import 'dart:collection';

import 'package:real_time_location/real_time_location.dart';

List<Map<String, Coordinates>> sortLocationsByDistance(
  Map<String, dynamic> locations,
) {
  final sortedLocationsList = <Map<String, Coordinates>>[];
  final locationsSortedByDistance = SplayTreeMap<String, dynamic>.from(
    locations,
    _compareKeys,
  ).values.toList();
  for (final location in locationsSortedByDistance) {
    location as Map;
    sortedLocationsList.add(
      {
        location.keys.first as String: _mapToCoordinates(
          location.values.first as Map<String, dynamic>,
        ),
      },
    );
  }
  return sortedLocationsList;
}

Coordinates _mapToCoordinates(Map<String, dynamic> coordinatesAsMap) =>
    Coordinates(
      latitude: coordinatesAsMap['lat'] as double,
      longitude: coordinatesAsMap['lon'] as double,
    );

int _compareKeys(String first, String second) {
  // (double.tryParse(first) - double.tryParse(second)).toInt();
  final firstDouble = double.tryParse(first);
  final secondDouble = double.tryParse(second);
  if (firstDouble == null || secondDouble == null) {
    throw ArgumentError('The keys must be double parsable');
  }
  return (firstDouble - secondDouble).toInt();
}
