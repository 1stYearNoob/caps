import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/colors/light_colors.dart';
import '../services/roboflow_service.dart';
import '../services/auth_service.dart';
import '../utils/disease_recommendation_helper.dart';
import '../services/translation_service.dart';

class ScanResultPage extends StatelessWidget {
  final File? image;
  final List<Detection>? detections;
  final bool isFromHistory;

  const ScanResultPage({
    super.key,
    this.image,
    this.detections,
    this.isFromHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    // If no real data, use 'Not Detected' fallback instead of dummy data
    final List<Detection> displayDetections = (detections == null || detections!.isEmpty)
        ? [Detection(0, 0, 0, 0, 0.0, 'Not Detected')]
        : detections!;

    // Sort detections by confidence (highest first)
    displayDetections.sort((a, b) => b.confidence.compareTo(a.confidence));
    final topDetection = displayDetections.first;

    bool isNotDetected = topDetection.label == 'Not Detected';

    // Determine colors based on confidence/disease
    bool isHealthy = topDetection.label.toLowerCase().contains('healthy') || isNotDetected;
    Color statusColor = isNotDetected ? Colors.grey : (isHealthy ? LightColors.kGreen : LightColors.kRed);
    IconData statusIcon = isNotDetected ? Icons.search_off : (isHealthy ? Icons.eco : Icons.coronavirus);
    
    // Get Recommendations Content
    Widget recommendationsContent = DiseaseRecommendationHelper.buildRecommendations(topDetection.label, isHealthy, isNotDetected, statusColor);

    Widget? diseaseManagementContent;
    Widget? nutrientDeficiencyContent;
    Widget? applyNutrientsContent;

    String labelLow = topDetection.label.toLowerCase();
    if (!isHealthy && !isNotDetected) {
      diseaseManagementContent = DiseaseRecommendationHelper.buildDiseaseManagement(labelLow, statusColor);
      nutrientDeficiencyContent = DiseaseRecommendationHelper.buildNutrientDeficiency(statusColor);
      applyNutrientsContent = DiseaseRecommendationHelper.buildApplyNutrients(labelLow, statusColor);
    }
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: LightColors.kDarkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analysis Result'.tr,
          style: const TextStyle(
            color: LightColors.kDarkBlue,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Image Preview Card (Left)
                Expanded(
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10.0,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: image != null
                        ? Image.file(image!, fit: BoxFit.cover)
                        : Image.asset('assets/rice blast.webp', fit: BoxFit.cover),
                  ),
                ),
                
                const SizedBox(width: 15),

                // Result Card (Right)
                Expanded(
                  child: Container(
                    height: 250,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10.0,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 30),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isNotDetected ? 'Unknown'.tr : (isHealthy ? 'Healthy'.tr : 'Disease'.tr),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          topDetection.label.tr,
                          style: const TextStyle(
                            color: LightColors.kDarkBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        // Confidence Pillar
                        Text(
                          'Confidence'.tr,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(topDetection.confidence * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: LightColors.kDarkBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Recommendations Section
            RecommendationCard(
              title: 'General Recommendations'.tr,
              content: recommendationsContent,
              isHealthy: isHealthy,
              statusColor: statusColor,
            ),

            if (diseaseManagementContent != null) ...[
              const SizedBox(height: 25),
              // Disease Management Section
              RecommendationCard(
                title: 'Disease Management'.tr,
                content: diseaseManagementContent,
                isHealthy: isHealthy,
                statusColor: statusColor,
              ),
            ],

            if (nutrientDeficiencyContent != null) ...[
              const SizedBox(height: 25),
              // Nutrient Deficiency Considerations Section
              RecommendationCard(
                title: 'Nutrient Deficiency Considerations'.tr,
                content: nutrientDeficiencyContent,
                isHealthy: isHealthy,
                statusColor: statusColor,
              ),
            ],

            if (applyNutrientsContent != null) ...[
              const SizedBox(height: 25),
              // Apply Nutrients based on soil test results Section
              RecommendationCard(
                title: 'Apply nutrients based on soil test results'.tr,
                content: applyNutrientsContent,
                isHealthy: isHealthy,
                statusColor: statusColor,
              ),
            ],

            const SizedBox(height: 25),

            // Action Buttons
            // Action Buttons
            if (!isFromHistory)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Discard / scan another
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.refresh, color: LightColors.kDarkBlue),
                      label: Text(
                        'Scan Again'.tr,
                        style: const TextStyle(color: LightColors.kDarkBlue, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(color: Colors.black12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final userId = AuthService().currentUserId;
                        if (userId != null) {
                          try {
                            String? savedImagePath;
                            if (image != null) {
                              final directory = await getApplicationDocumentsDirectory();
                              final String fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
                              final File savedImage = await image!.copy('${directory.path}/$fileName');
                              savedImagePath = savedImage.path;
                            }

                             // Fetch user's saved rice field location
                             final userDoc = await FirebaseFirestore.instance
                                 .collection('users')
                                 .doc(userId)
                                 .get();

                             double? rfLat;
                             double? rfLng;
                             if (userDoc.exists && userDoc.data() != null) {
                               final data = userDoc.data() as Map<String, dynamic>;
                               rfLat = (data['riceFieldLatitude'] as num?)?.toDouble();
                               rfLng = (data['riceFieldLongitude'] as num?)?.toDouble();
                             }

                             await FirebaseFirestore.instance
                                 .collection('users')
                                 .doc(userId)
                                 .collection('scan_history')
                                 .add({
                               'diseaseName': topDetection.label,
                               'confidence': topDetection.confidence,
                               'isHealthy': isHealthy,
                               'timestamp': FieldValue.serverTimestamp(),
                               'imagePath': savedImagePath,
                               'riceFieldLatitude': rfLat,
                               'riceFieldLongitude': rfLng,
                             });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Saved to History!'.tr)),
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to save: '.tr + e.toString())),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please log in to save result.'.tr)),
                          );
                        }
                      },
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        'Save Result'.tr,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LightColors.kDarkBlue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class RecommendationCard extends StatefulWidget {
  final String title;
  final Widget content;
  final bool isHealthy;
  final Color statusColor;

  const RecommendationCard({
    super.key,
    required this.title,
    required this.content,
    required this.isHealthy,
    required this.statusColor,
  });

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: widget.isHealthy
              ? LightColors.kGreen.withOpacity(0.3)
              : LightColors.kRed.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: _isExpanded 
                ? const BorderRadius.vertical(top: Radius.circular(20))
                : BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.statusColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lightbulb_outline, 
                            color: widget.statusColor, 
                            size: 20
                          ),
                        ),
                        const SizedBox(width: 15),
                        Flexible(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: LightColors.kDarkBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_up,
                        color: LightColors.kDarkBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: SizedBox(
              width: double.infinity,
              child: _isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, thickness: 1, color: Colors.black12),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: widget.content, // Includes the content passed internally
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
