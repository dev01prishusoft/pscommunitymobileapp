import 'package:flutter/material.dart';

class BusinessCategory {
  final String title;
  final IconData icon;

  const BusinessCategory({
    required this.title,
    required this.icon,
  });
}

abstract class BusinessRepository {
  Future<List<BusinessCategory>> getCategories();
}
