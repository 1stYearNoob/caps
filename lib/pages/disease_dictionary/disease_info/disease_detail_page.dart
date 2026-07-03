import 'package:flutter/material.dart';
import '../../../theme/colors/light_colors.dart';
import '../../../services/translation_service.dart';

class DiseaseDetailPage extends StatelessWidget {
  final Map<String, dynamic> disease;

  const DiseaseDetailPage({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with disease image
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: disease['color'] ?? LightColors.kDarkBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: disease['imagePath'] != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          disease['imagePath'],
                          fit: BoxFit.cover,
                        ),
                        // Gradient overlay for readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: disease['color'] ?? LightColors.kDarkBlue,
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.white54,
                        size: 80,
                      ),
                    ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease Name
                  Text(
                    disease['name'].toString().tr,
                    style: const TextStyle(
                      color: LightColors.kDarkBlue,
                      fontSize: 26.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Info Chips Row
                  Wrap(
                    spacing: 10.0,
                    runSpacing: 8.0,
                    children: [
                      _buildInfoChip(
                        icon: Icons.category_outlined,
                        label: disease['category'].toString().tr,
                        color: LightColors.kDarkBlue,
                      ),
                      _buildInfoChip(
                        icon: Icons.warning_amber_rounded,
                        label: '${'Severity'.tr}: ${disease['severity'].toString().tr}',
                        color: disease['color'] ?? LightColors.kDarkYellow,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),

                  // Pathogen Section
                  _buildSectionCard(
                    title: 'Pathogen'.tr,
                    icon: Icons.coronavirus_outlined,
                    child: Text(
                      disease['pathogen'].toString().tr,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),

                  // Summary Section
                  if (disease['summary'] != null)
                    _buildSectionCard(
                      title: 'Summary'.tr,
                      icon: Icons.summarize_outlined,
                      child: Text(
                        disease['summary'].toString().tr,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  if (disease['summary'] != null)
                    const SizedBox(height: 15.0),

                  // Description Section
                  if (disease['description'] != null)
                    _buildSectionCard(
                      title: 'Description'.tr,
                      icon: Icons.info_outline_rounded,
                      child: Text(
                        disease['description'].toString().tr,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),
                    ),
                  const SizedBox(height: 30.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.0, color: color),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.0, color: LightColors.kDarkBlue),
              const SizedBox(width: 8.0),
              Text(
                title,
                style: const TextStyle(
                  color: LightColors.kDarkBlue,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          child,
        ],
      ),
    );
  }
}
