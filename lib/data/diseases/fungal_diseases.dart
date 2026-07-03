import 'package:flutter/material.dart';
import '../../theme/colors/light_colors.dart';

final List<Map<String, dynamic>> fungalDiseases = [
  {
    'name': 'Rice Blast',
    'category': 'Fungal',
    'pathogen': 'Magnaporthe oryzae',
    'severity': 'High',
    'icon': Icons.grain,
    'color': LightColors.kRed,
    'imagePath': 'assets/rice blast.webp',
    'summary': 'A common fungal disease in rice caused by Magnaporthe oryzae. It appears as diamond-shaped lesions with gray centers and brown edges on leaves, stems, and panicles. Severe infection can reduce grain yield and quality.',
    'description': 'A destructive fungal disease of rice caused by Magnaporthe oryzae. It appears as diamond-shaped spots with gray centers and brown edges on leaves, stems, and panicles. The disease spreads through spores carried by wind and rain. It commonly develops in cool, humid conditions and can greatly reduce rice yield and grain quality. Proper field sanitation and resistant rice varieties help control the disease.',
  },
  {
    'name': 'Brown Spot',
    'category': 'Fungal',
    'pathogen': 'Bipolaris oryzae',
    'severity': 'Medium',
    'icon': Icons.circle_outlined,
    'color': LightColors.kBlue,
    'imagePath': 'assets/brownspot.jpg',
    'summary': 'A fungal disease caused by Bipolaris oryzae. It produces small brown circular or oval spots on rice leaves and grains. The disease is often associated with poor soil nutrition and can lower rice production.',
    'description': 'A fungal disease caused by Bipolaris oryzae that affects rice leaves, grains, and seedlings. Symptoms include brown circular or oval spots on leaves and discolored grains. It is common in nutrient-deficient soils and drought-stressed fields. Severe infection can weaken plants and lower grain production. Balanced fertilization and healthy seed use are recommended for prevention.',
  },
];
