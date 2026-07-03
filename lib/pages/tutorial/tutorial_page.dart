import 'package:flutter/material.dart';
import '../../theme/colors/light_colors.dart';
import '../../services/translation_service.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _tutorialSlides = [
    {
      'image': 'assets/1.jpg',
      'title': 'Home Screen',
      'description': 'View your tasks, access tutorials, and navigate the app from the home screen.',
    },
    {
      'image': 'assets/2.jpg',
      'title': 'Weather Monitor',
      'description': 'Monitor real-time weather data for your rice field area with AI-powered advice.',
    },
    {
      'image': 'assets/3.jpg',
      'title': 'Disease Dictionary',
      'description': 'Browse all rice diseases the app can detect, with detailed information and images.',
    },
    {
      'image': 'assets/4.jpg',
      'title': 'Location Mapping',
      'description': 'Mark and save your rice field location on the map for tracking and admin reports.',
    },
    {
      'image': 'assets/5.jpg',
      'title': 'Scan History',
      'description': 'View your past scan results, track issues found, and report concerns to admin.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showZoomableImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              backgroundColor: Colors.black87,
              body: Stack(
                children: [
                  // Zoomable image
                  Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Close button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    right: 15,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: LightColors.kDarkBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Tutorial'.tr,
          style: const TextStyle(
            color: LightColors.kDarkBlue,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          // Page indicator text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_currentPage + 1} / ${_tutorialSlides.length}',
                  style: const TextStyle(
                    color: LightColors.kDarkBlue,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Image Carousel
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _tutorialSlides.length,
              itemBuilder: (context, index) {
                final slide = _tutorialSlides[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Column(
                    children: [
                      // Image (tap to zoom)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _showZoomableImage(context, slide['image']!);
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 15.0,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.0),
                              child: Image.asset(
                                slide['image']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Title
                      Text(
                        slide['title']!.tr,
                        style: const TextStyle(
                          color: LightColors.kDarkBlue,
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          slide['description']!.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                );
              },
            ),
          ),

          // Dot Indicators & Navigation
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0, top: 10.0),
            child: Column(
              children: [
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _tutorialSlides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 10.0,
                      width: _currentPage == index ? 28.0 : 10.0,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? LightColors.kDarkBlue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          'Back'.tr,
                          style: const TextStyle(
                            color: LightColors.kDarkBlue,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 80),

                    // Next / Done button
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _tutorialSlides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LightColors.kDarkBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 14.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      child: Text(
                        _currentPage < _tutorialSlides.length - 1
                            ? 'Next'.tr
                            : 'Done'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
