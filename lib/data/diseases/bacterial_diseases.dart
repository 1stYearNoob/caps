import 'package:flutter/material.dart';
import '../../theme/colors/light_colors.dart';

final List<Map<String, dynamic>> bacterialDiseases = [
  {
    'name': 'Bacterial Blight',
    'category': 'Bacterial',
    'pathogen': 'Xanthomonas oryzae',
    'severity': 'High',
    'icon': Icons.coronavirus,
    'color': LightColors.kDarkYellow,
    'imagePath': 'assets/bacterial leaft blight.avif',
    'summary': 'A serious bacterial disease caused by Xanthomonas oryzae pv. oryzae. It causes yellowing and drying of leaf edges that spread downward, leading to wilted leaves and reduced yield, especially during wet conditions.',
    'description': 'A bacterial disease caused by Xanthomonas oryzae pv. oryzae. It causes yellowing and drying of leaf tips and edges, which later spread along the leaf blade. The bacteria spread through water, rain splash, and infected tools or plants. Warm and wet weather favors the disease. It can cause serious yield loss in susceptible rice varieties. Clean farming practices and resistant varieties are effective control measures.',
  },
  {
    'name': 'Bacterial Sheath Blight',
    'category': 'Bacterial',
    'pathogen': 'Rhizoctonia solani',
    'severity': 'Medium',
    'icon': Icons.coronavirus,
    'color': LightColors.kDarkYellow,
    'imagePath': 'assets/bacterial sheath blight.jpg',
    'summary': 'A rice disease commonly caused by the fungus Rhizoctonia solani. It forms greenish-gray lesions on the leaf sheath near the waterline, which later enlarge and damage leaves. The disease spreads quickly in dense and highly fertilized rice fields.',
    'description': 'A common rice disease caused by the fungus Rhizoctonia solani. It begins as greenish-gray lesions on the leaf sheath near the water level and later spreads to leaves. The disease develops rapidly in dense rice fields with high nitrogen fertilizer use and humid conditions. Severe infection weakens the plant and reduces grain filling. Proper spacing and balanced fertilizer application help reduce disease spread.',
  },
];
