import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cartelle/core/constants/constants.dart';
import 'package:cartelle/core/constants/route_constants.dart';
import 'package:cartelle/core/permissions/notification_permission.dart';
import 'package:cartelle/core/sevices/geofence_location.dart';
import 'package:cartelle/features/auth/controller/auth_controller.dart';
import 'package:cartelle/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int activeIndex = 0;
  final PageController _pageController = PageController();
  int activeIndexForSegment = 0;
  bool _notificationRequested = false;
  bool _exactAlarmGranted = false;
  BorderRadius dynamicBorder = const BorderRadius.only(
    topLeft: Radius.circular(20),
    bottomLeft: Radius.circular(20),
  );

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestOnce();
      final geofenceService = GeofenceLocation(ref: ref);
      geofenceService.initGeofences();
    });
  }

  void _requestOnce() {
    if (!_notificationRequested) {
      _notificationRequested = true;
      requestNotificationPermissions(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    void onTap(int index) {
      setState(() {
        activeIndex = index;
      });
    }

    return Scaffold(
      appBar:
          activeIndex == 1
              ? null
              : AppBar(
                title: Text(
                  activeIndex == 0
                      ? "Cartelle"
                      : activeIndex == 1
                      ? "Reminders"
                      : activeIndex == 2
                      ? "Locations"
                      : "Profile",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
                centerTitle: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      ref
                          .read(authControllerProvider.notifier)
                          .signOut(context); // logout
                      context.goNamed(RouteConstants.loginRoute);
                    },
                  ),
                ],
              ),

      body:
          // 🔹 PageView for smooth transitions
          Constants().pages[activeIndex],

      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 10,
        buttonSize: const Size(56, 56),
        iconTheme: const IconThemeData(size: 24),
        useRotationAnimation: true,
        spaceBetweenChildren: 5,
        backgroundColor: AppTheme.cupcakeLightTheme.colorScheme.primary,
        overlayOpacity: 0.2,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.store),
            label: 'Add Shopping List',
            onTap: () {
              context.pushNamed(RouteConstants.addListRoute);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.alarm),
            label: 'Add Reminder',
            onTap: () {
              context.pushNamed(RouteConstants.addReminderRoute);
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: Constants().icons,
        activeIndex: activeIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 28,
        rightCornerRadius: 28,
        backgroundColor: AppTheme.cupcakeLightTheme.scaffoldBackgroundColor,
        activeColor: AppTheme.cupcakeLightTheme.iconTheme.color,
        inactiveColor: AppTheme.cupcakeLightTheme.hintColor.withAlpha(
          (0.4 * 255).toInt(),
        ),
        splashColor: AppTheme.cupcakeLightTheme.colorScheme.primary.withAlpha(
          (0.3 * 255).toInt(),
        ),
        elevation: 12,
        iconSize: 26,
        onTap: onTap,
        shadow: BoxShadow(
          color: Colors.black12,
          blurRadius: 12,
          spreadRadius: 1,
          offset: const Offset(0, -2),
        ),
      ),
    );
  }
}
