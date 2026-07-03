import 'package:flutter/material.dart';
import 'bottom_nav_item.dart';

class HomeBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const HomeBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BottomNavItem(
              icon: Icons.description,
              label: 'Disease',
              isSelected: selectedIndex == 0,
              onTap: () => onItemTapped(0),
            ),
            BottomNavItem(
              icon: Icons.cloud_outlined,
              label: 'Weather',
              isSelected: selectedIndex == 1,
              onTap: () => onItemTapped(1),
            ),
            // Placed squarely in the middle (replacing the previous gap)
            BottomNavItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: selectedIndex == 2,
              onTap: () => onItemTapped(2),
            ),
            BottomNavItem(
              icon: Icons.location_on_outlined,
              label: 'Location',
              isSelected: selectedIndex == 3,
              onTap: () => onItemTapped(3),
            ),
            BottomNavItem(
              icon: Icons.history,
              label: 'History',
              isSelected: selectedIndex == 4,
              onTap: () => onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}
