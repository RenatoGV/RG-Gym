import 'package:flutter/material.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/screens/tabs/stats/tabs/activities.dart';
import 'package:rg_gym/screens/tabs/stats/tabs/history.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            const TabBar(
              indicatorColor: AppColors.primary,
              dividerHeight: 0,
              indicatorSize: .tab,
              labelColor: AppColors.primary,
              tabs: [
                Tab(text: "Actividades"),
                Tab(text: "Histórico"),
              ],
            ),

            const Expanded(
              child: TabBarView(
                children: [
                  ActivitiesScreen(),
                  HistoryScreen()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}