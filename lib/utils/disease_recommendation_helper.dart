import 'package:flutter/material.dart';
import '../theme/colors/light_colors.dart';
import '../services/translation_service.dart';

class DiseaseRecommendationHelper {
  // Helper method to build recommendations widget
  static Widget buildRecommendations(String diseaseName, bool isHealthy, bool isNotDetected, Color statusColor) {
    if (isNotDetected) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: statusColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: AiTranslatedText(
                    'The scanner did not detect any known diseases or recognizable patterns in this image. Please try scanning again with a clearer picture of the affected leaves or crops.',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    }

    if (isHealthy) {
      final List<String> recs = [
        'Continue current watering and fertilizer schedules.',
        'Maintain regular monitoring for early detection of any future issues.',
        'Ensure proper spacing between crops to allow air circulation.'
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: recs.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, color: statusColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: AiTranslatedText(
                  rec,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      );
    }

    List<Widget> content = [];
    String labelLow = diseaseName.toLowerCase();
    
    if (labelLow.contains('blast')) {
      content.addAll([
        buildSectionHeader('Causes:'),
        AiTranslatedText(
          'Rice Blast often develops and favors rice plants exposed to:',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 15),
        buildBulletPoint('Excessive nitrogen fertilizer, which leads to soft, succulent, disease-susceptible tissues.', statusColor),
        buildBulletPoint('Low silicon availability (commonly associated with poor soil fertility or imbalanced nutrient use).', statusColor),
        buildBulletPoint('High humidity, frequent drizzles, cloudiness, and temperatures between 20–28°C.', statusColor),
        buildBulletPoint('Long dew period, water scarcity with high night humidity, and low night temperature.', statusColor),
        const SizedBox(height: 25),
        const Divider(),
        const SizedBox(height: 25),
      ]);
    } else if (labelLow.contains('brown spot')) {
      content.addAll([
        buildSectionHeader('Causes:'),
        AiTranslatedText(
          'Brown Spot often develops and favors rice plants exposed to:',
          style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        buildBulletPoint('Soil nutrient deficiencies (especially low nitrogen, potassium, and silicon).', statusColor),
        buildBulletPoint('Water stress or poor water management.', statusColor),
        buildBulletPoint('High humidity and temperatures (25-30°C).', statusColor),
        const SizedBox(height: 25),
        const Divider(),
        const SizedBox(height: 25),
      ]);
    } else if (labelLow.contains('bacterial-leaf-blight') || labelLow.contains('bacterial leaf blight')) {
      content.addAll([
        buildSectionHeader('Causes:'),
        AiTranslatedText(
          'Bacterial Leaf Blight often develops and favors rice plants exposed to:',
          style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        buildBulletPoint('Typhoons, heavy rains, and strong winds that create wounds on leaves.', statusColor),
        buildBulletPoint('Excessive nitrogen fertilizer.', statusColor),
        buildBulletPoint('High temperatures (25-34°C) and high humidity (above 70%).', statusColor),
        const SizedBox(height: 25),
        const Divider(),
        const SizedBox(height: 25),
      ]);
    } else if (labelLow.contains('sheath blight')) {
      content.addAll([
        buildSectionHeader('Causes:'),
        AiTranslatedText(
          'Sheath Blight often develops and favors rice plants exposed to:',
          style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        buildBulletPoint('High seeding rate or dense planting, causing poor air circulation.', statusColor),
        buildBulletPoint('Excessive nitrogen application.', statusColor),
        buildBulletPoint('High temperatures (28-32°C) and high humidity.', statusColor),
        const SizedBox(height: 25),
        const Divider(),
        const SizedBox(height: 25),
      ]);
    }

    content.addAll([
      AiTranslatedText(
        '${diseaseName.tr} can be caused by nutrient deficiencies, a soil analysis may reveal the specific nutrients the plant may need:',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 15),
      buildSectionHeader('Pointers in Soil Sampling:'),
      buildBulletPoint('Collect soil samples after harvest when the field is dry, and away from outlying areas of the field.', statusColor),
      buildBulletPoint('Collect one composite sample from each field having the same color, texture, slope, class, depth, drainage, and cropping history.', statusColor),
      const SizedBox(height: 15),
      buildSectionHeader('Materials:'),
      buildBulletPoint('Long-handled shovel', statusColor),
      buildBulletPoint('Trowel', statusColor),
      buildBulletPoint('Plastic bags', statusColor),
      buildBulletPoint('Pentel pen', statusColor),
      const SizedBox(height: 15),
      buildSectionHeader('Steps in Sampling:'),
      buildBulletPoint('Remove plant residues in the soil surface.', statusColor),
      buildBulletPoint('Dig to about 20cm deep.', statusColor),
      buildBulletPoint('Slice about 5-cm-thick soil samples from the verticle side.', statusColor),
      buildBulletPoint('Collect about 10-cm wide of the middle part of the vertical slice and place in a container.', statusColor),
      buildBulletPoint('Take samples from three random points of each field to be tested.', statusColor),
      buildBulletPoint('Mix all samples thoroughly. Take 1kg from the composite sample and place in a plastic bag.', statusColor),
      buildBulletPoint('Put label (i.e., location, name, date of sampling, and cropping season) on the plastic bag.', statusColor),
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content,
    );
  }

  // Helper method for the separate Disease Management block
  static Widget buildDiseaseManagement(String labelLow, Color statusColor) {
    List<Widget> managementPoints = [];

    if (labelLow.contains('blast')) {
      managementPoints = [
        buildBulletPoint('Reduce excessive nitrogen fertilization, especially during early vegetative stages.', statusColor),
        buildBulletPoint('Remove infected plant residues and maintain good field sanitation. Use varieties with improved blast resistance when available.', statusColor),
        buildBulletPoint('Avoid water stress.', statusColor),
        buildBulletPoint('Raise seedlings on wet bed.', statusColor),
      ];
    } else if (labelLow.contains('brown spot')) {
      managementPoints = [
        buildBulletPoint('Ensure a balanced nutrient supply (nitrogen, phosphorus, potassium, and silicon).', statusColor),
        buildBulletPoint('Monitor water levels carefully to avoid water stress.', statusColor),
        buildBulletPoint('Use certified, disease-free seeds and consider seed treatment.', statusColor),
      ];
    } else if (labelLow.contains('bacterial')) {
      managementPoints = [
        buildBulletPoint('Reduce nitrogen application during the susceptible stage.', statusColor),
        buildBulletPoint('Ensure good field drainage, especially during heavy rains or typhoons.', statusColor),
        buildBulletPoint('Remove and destroy infected weeds and volunteer rice plants.', statusColor),
        buildBulletPoint('Plant resistant varieties in areas prone to bacterial blight.', statusColor),
      ];
    } else if (labelLow.contains('sheath blight')) {
      managementPoints = [
        buildBulletPoint('Lower the seeding rate or use wider plant spacing to improve air circulation.', statusColor),
        buildBulletPoint('Avoid heavy nitrogen application.', statusColor),
        buildBulletPoint('Keep the field free of weeds that could serve as alternative hosts.', statusColor),
        buildBulletPoint('Apply recommended fungicides if the disease reaches the economic threshold.', statusColor),
      ];
    } else {
      managementPoints = [
        buildBulletPoint('Remove infected plant parts immediately.', statusColor),
        buildBulletPoint('Monitor field conditions closely and consult an agricultural extension worker.', statusColor),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: managementPoints,
    );
  }

  // Helper method for the separate Nutrient Deficiency block
  static Widget buildNutrientDeficiency(Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiTranslatedText(
          'A rice crop needs the following uptake of N (Nitrogen), P (Phosphorus), and K (Potassium) to produce 1 ton of grain per hectare:',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        buildBulletPoint('Nitrogen (N): 15–20 kg', statusColor),
        buildBulletPoint('Phosphorus (P): 2–3 kg', statusColor),
        buildBulletPoint('Potassium (K): 15–20 kg', statusColor),
        AiTranslatedText(
          '(If rice straw is retained and evenly distributed in the field, K requirement can drop to 3–5 kg/ha per ton.)',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // Helper method for Apply Nutrients block
  static Widget buildApplyNutrients(String labelLow, Color statusColor) {
    String nutrientAdvice = '';

    if (labelLow.contains('blast')) {
      nutrientAdvice = 'For Rice Blast, it is recommended to carefully moderate nitrogen use, ensuring it is applied in split doses rather than as a heavy single application. Maintaining adequate silicon, phosphorus, and potassium levels helps strengthen cell walls and reduce susceptibility.';
    } else if (labelLow.contains('brown spot')) {
      nutrientAdvice = 'For Brown Spot, correcting soil nutrient deficiencies is crucial. Ensure adequate levels of nitrogen, potassium, and especially silicon. A soil test will help determine exactly which nutrients are lacking.';
    } else if (labelLow.contains('bacterial')) {
      nutrientAdvice = 'For Bacterial Leaf Blight, avoid applying too much nitrogen, especially in a single dose, as this promotes soft tissue growth that the bacteria can easily infect. Balanced NPK fertilization is recommended.';
    } else if (labelLow.contains('sheath blight')) {
      nutrientAdvice = 'For Sheath Blight, avoid over-fertilization with nitrogen. Split nitrogen applications help prevent dense canopies that trap humidity and favor the disease. Ensure potassium levels are adequate.';
    } else {
      nutrientAdvice = 'Apply fertilizers in balanced amounts based on soil test recommendations. Avoid excessive nitrogen, which can increase susceptibility to many diseases.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiTranslatedText(
          nutrientAdvice,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  static Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.tr,
        style: const TextStyle(
          color: LightColors.kDarkBlue,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget buildBulletPoint(String text, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, color: statusColor, size: 6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AiTranslatedText(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
