import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('AgriScan'),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      leading: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
      ),
      // Removed logout action as requested
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
