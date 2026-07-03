import 'package:flutter/material.dart';
import '../theme/colors/light_colors.dart';

class HowToPlantPage extends StatelessWidget {
  const HowToPlantPage({super.key});

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: LightColors.kDarkBlue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      appBar: AppBar(
        title: const Text(
          'How to Plant Rice',
          style: TextStyle(
            color: LightColors.kDarkBlue,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: LightColors.kDarkBlue),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro Text
            const Text(
              'The planting of rice can be done in various ways. The choice of the method to be used depends on the goals and abilities of the farmer. There are two common methods of planting: direct-seeding and transplanting.',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // Dropdown Sections
            const Text(
              'Detailed Methods',
              style: TextStyle(
                fontSize: 22.0,
                color: LightColors.kDarkBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 15),

            // Sabog-Tanim Dropdown
            _buildSectionCard(
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent, // Removes the divider line
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: LightColors.kLightYellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.grass, color: LightColors.kDarkYellow),
                  ),
                  title: const Text(
                    'Sabog-tanim',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: LightColors.kDarkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Direct-Seeding Method',
                    style: TextStyle(color: Colors.black54),
                  ),
                  children: [
                    const Text(
                      'No need to grow, uproot, and transplant the seedlings because they will be planted directly in the ground.',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/sabog.png',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildBulletPoint('7-10 days faster the growth of rice compared to the method transplanting.'),
                    _buildBulletPoint('Requires lively and strong variations in making this. It is also important to have additional that plants have protection against pests and weeds.'),
                    _buildBulletPoint('There are three methods of broadcasting seeds: broadcasting on wet and dry soil, and modified dry direct seeding.'),
                  ],
                ),
              ),
            ),

            // Lipat Tanim Dropdown
            _buildSectionCard(
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent, // Removes the divider line
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: LightColors.kLightYellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.eco, color: LightColors.kGreen),
                  ),
                  title: const Text(
                    'Lipat Tanim',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: LightColors.kDarkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Transplanting Method',
                    style: TextStyle(color: Colors.black54),
                  ),
                  children: [
                    const Text(
                      'The seeds need to be germinated first. Seeds in the seedbed before it is planted in the field. This is done to ensure the seedlings grow well and they will be protected against weeds and pests.',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildBulletPoint('It\'s easier to maintain equal and consistent spacing and number of seedlings if they are planted in rows.'),
                    _buildBulletPoint('In preparing the seedlings to be transferred, you can use a wetbed, drybed, modified dapog, and mat nursery.'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              'Pros & Cons Comparison',
              style: TextStyle(
                fontSize: 22.0,
                color: LightColors.kDarkBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 15),

            // Pros and Cons Sabog Tanim
            _buildSectionCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: LightColors.kDarkYellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.grass, color: LightColors.kDarkYellow),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          'Sabog-Tanim',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: LightColors.kDarkBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildBulletPoint('Requires additional protection against snails, birds, rats, and other pests and weeds.'),
                    _buildBulletPoint('Difficult to care for because the seeds are immediately scattered all over the field.'),
                    _buildBulletPoint('More seeds are needed.'),
                    _buildBulletPoint('No need to prepare seedbed, uproot seedlings, and transplant.'),
                  ],
                ),
              ),
            ),

            // Pros and Cons Lipat Tanim
            _buildSectionCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: LightColors.kGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.eco, color: LightColors.kGreen),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          'Lipat-Tanim',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: LightColors.kDarkBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildBulletPoint('Stronger against snails, birds, rats, and other pests and weeds.'),
                    _buildBulletPoint('Easy to care for because of seedbed where the seeds will sprout.'),
                    _buildBulletPoint('Only a few seeds are needed.'),
                    _buildBulletPoint('Additional costs are the uprooting and planting seedlings.'),
                    _buildBulletPoint('It is done only in wet soil.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
