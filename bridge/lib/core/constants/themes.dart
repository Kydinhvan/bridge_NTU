import 'package:flutter/material.dart';

class AppThemes {
  static const List<String> all = [
    'Exam Stress / Academic Pressure',
    'Family Problems',
    'Friendship / Social Issues',
    'Burnout / Emotional Exhaustion',
    'Loneliness / Isolation',
    'Life Direction / Purpose',
    'Self-Confidence / Self-Esteem',
  ];

  // Legacy String map kept for backwards compat — values are now empty
  static const Map<String, String> icons = {
    'Exam Stress / Academic Pressure': '',
    'Family Problems': '',
    'Friendship / Social Issues': '',
    'Burnout / Emotional Exhaustion': '',
    'Loneliness / Isolation': '',
    'Life Direction / Purpose': '',
    'Self-Confidence / Self-Esteem': '',
  };

  static const Map<String, IconData> iconData = {
    'Exam Stress / Academic Pressure': Icons.menu_book_rounded,
    'Family Problems': Icons.home_rounded,
    'Friendship / Social Issues': Icons.people_rounded,
    'Burnout / Emotional Exhaustion': Icons.local_fire_department_rounded,
    'Loneliness / Isolation': Icons.nights_stay_rounded,
    'Life Direction / Purpose': Icons.explore_rounded,
    'Self-Confidence / Self-Esteem': Icons.self_improvement_rounded,
  };
}
