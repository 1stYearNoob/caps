import 'package:flutter/material.dart';
import '../widgets/home_bottom_bar.dart';
import '../theme/colors/light_colors.dart';

// Pages
import 'home/home_content.dart';
import 'disease_dictionary/disease_dictionary_page.dart';
import 'weather/weather_page.dart';
import 'location/location_page.dart';
import 'history/history_page.dart';
import 'disease_detector_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Default to 'Home' icon in the middle
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Handle Bottom Navigation Bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Animate to the selected page
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Handle PageView swipes
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(), // Add bounce effect when swiping beyond edges
        children: const [
          DiseaseDictionaryPage(),
          WeatherPage(),
          HomeContent(), // The original home screen content
          LocationPage(),
          HistoryPage(),
        ],
      ),
      floatingActionButton: _selectedIndex == 2
          ? Container(
              height: 70,
              width: 70,
              margin: const EdgeInsets.only(bottom: 25.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DiseaseDetectorPage(),
                    ),
                  );
                },
                backgroundColor: Colors.green,
                elevation: 4.0,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: HomeBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
