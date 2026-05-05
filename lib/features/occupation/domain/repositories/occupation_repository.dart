import 'package:flutter/material.dart';

class OccupationItem {
  final String name;
  final int count;
  final IconData icon;

  const OccupationItem({
    required this.name,
    required this.count,
    required this.icon,
  });
}

abstract class OccupationRepository {
  Future<List<OccupationItem>> getOccupations();
}
