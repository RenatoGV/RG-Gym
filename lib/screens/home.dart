import 'package:flutter/material.dart';
import 'package:rg_gym/config/menu/menu_items.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/screens/tabs/exercises/exercises.dart';
import 'package:rg_gym/screens/tabs/routines/routines.dart';
import 'package:rg_gym/screens/tabs/stats/stats.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final pages = const [
    RoutinesScreen(),
    StatsScreen(),
    Exercises()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: currentIndex,
        onChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        }
      ),
    );
  }
}

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onChanged
  });
  
  @override
  Widget build(BuildContext context) {
    return
    NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: AppColors.primary,
        height: 70,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: Colors.white,
              );
            }

            return IconThemeData(
              color: Colors.white,
            );
          },
        )
      ),
      child: NavigationBar(
        backgroundColor: AppColors.backgroundSecondary,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: currentIndex,
        onDestinationSelected: onChanged,
        destinations: appMenuItems.map((item) {
          return NavigationDestination(
            icon: item.icon,
            selectedIcon: item.icon,
            label: item.title
          );
        }).toList(),
      )
    );
  }
}