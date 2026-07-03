import 'package:flutter/material.dart';
import '../../theme/colors/light_colors.dart';
import '../../services/translation_service.dart';
import 'disease_info/disease_detail_page.dart';

// Data Imports
import '../../data/diseases/fungal_diseases.dart';
import '../../data/diseases/bacterial_diseases.dart';
import '../../data/diseases/viral_diseases.dart';
import '../../data/diseases/healthy_status.dart';

class DiseaseDictionaryPage extends StatefulWidget {
  const DiseaseDictionaryPage({super.key});

  @override
  State<DiseaseDictionaryPage> createState() => _DiseaseDictionaryPageState();
}

class _DiseaseDictionaryPageState extends State<DiseaseDictionaryPage> {
  final List<String> _categories = ['All', 'Fungal', 'Bacterial', 'Viral', 'Pests', 'Nutrient'];
  String _selectedCategory = 'All';

  // Combined Data for the Dictionary
  final List<Map<String, dynamic>> _allDiseases = [
    ...fungalDiseases,
    ...bacterialDiseases,
    ...viralDiseases,
    ...healthyStatus,
    // Add additional pests or nutrient deficiencies here over time
  ];

  @override
  Widget build(BuildContext context) {
    // Filter the list based on the selected category
    List<Map<String, dynamic>> filteredDiseases = _selectedCategory == 'All'
        ? _allDiseases
        : _allDiseases.where((disease) => disease['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Disease Dictionary'.tr,
          style: const TextStyle(
            color: LightColors.kDarkBlue,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Text(
              'Categories'.tr,
              style: const TextStyle(
                color: LightColors.kDarkBlue,
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Horizontal Category List
          SizedBox(
            height: 40.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: isSelected ? LightColors.kDarkBlue : Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        if (!isSelected)
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5.0,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category.tr,
                      style: TextStyle(
                        color: isSelected ? Colors.white : LightColors.kDarkBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 15.0),
          // Vertical Disease List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              itemCount: filteredDiseases.length,
              itemBuilder: (context, index) {
                final disease = filteredDiseases[index];
                return _buildDiseaseCard(disease);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(Map<String, dynamic> disease) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiseaseDetailPage(disease: disease),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10.0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              // Disease Image
              Container(
                height: 60,
                width: 60,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: disease['imagePath'] != null
                    ? Image.asset(
                        disease['imagePath'],
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                        size: 30.0,
                      ),
              ),
              const SizedBox(width: 15.0),
              // Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease['name'].toString().tr,
                      style: const TextStyle(
                        color: LightColors.kDarkBlue,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      disease['pathogen'].toString().tr,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Severity Badge & Arrow
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: disease['color'],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  disease['severity'].toString().tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14.0,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
