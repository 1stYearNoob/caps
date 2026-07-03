import 'package:flutter/material.dart';
import '../../theme/colors/light_colors.dart';

final List<Map<String, dynamic>> healthyStatus = [
  {
    'name': 'Healthy',
    'category': 'All', // 'All' category ensures it shows up on the main page
    'pathogen': 'No pathogens detected',
    'severity': 'None',
    'icon': Icons.spa,
    'color': LightColors.kGreen,
    'imagePath': 'assets/healthy.webp',
    'description': 'The rice plant is healthy with no signs of disease, pest damage, or nutrient deficiency. Leaves are green and vibrant, stems are strong, and growth is normal. Continue regular monitoring and good agricultural practices to maintain plant health.',
  },
];
