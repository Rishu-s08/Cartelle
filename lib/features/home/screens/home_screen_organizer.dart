import 'package:cartelle/features/home/screens/show_list_screen.dart';
import 'package:cartelle/features/home/screens/show_reminder_screen.dart';
import 'package:cartelle/theme/app_theme.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';

class HomeScreenOrganizer extends StatefulWidget {
  const HomeScreenOrganizer({super.key});

  @override
  State<HomeScreenOrganizer> createState() => _HomeScreenOrganizerState();
}

class _HomeScreenOrganizerState extends State<HomeScreenOrganizer> {
  @override
  Widget build(BuildContext context) {
    int activeIndex = 0;
    final PageController _pageController = PageController();

    return Scaffold(
      body: Column(
        children: [
          // 🔹 Custom segmented control
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomSlidingSegmentedControl<int>(
              initialValue: activeIndex,
              children: const {
                0: Text('Location Based', textAlign: TextAlign.center),
                1: Text('Reminder Based', textAlign: TextAlign.center),
              },
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              thumbDecoration: BoxDecoration(
                color: AppTheme.cupcakeLightTheme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: Offset(0.0, 2.0),
                  ),
                ],
              ),
              onValueChanged: (value) {
                setState(() => activeIndex = value);
                _pageController.animateToPage(
                  value,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
          // 🔹 PageView for smooth transitions
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [ShowListScreen(), ShowReminderScreen()],
            ),
          ),
        ],
      ),
    );
  }
}
