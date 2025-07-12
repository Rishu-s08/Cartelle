import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cartelle/core/constants/constants.dart';
import 'package:cartelle/core/constants/route_constants.dart';
import 'package:cartelle/features/add_list/screen/add_list_screen.dart';
import 'package:cartelle/features/auth/controller/auth_controller.dart';
import 'package:cartelle/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    void onTap(int index) {
      setState(() {
        activeIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cartelle",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall!.copyWith(fontSize: 26),
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
      body: Constants().pages[activeIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.cupcakeLightTheme.colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        elevation: 6,
        child: Icon(
          Icons.add,
          color: AppTheme.cupcakeLightTheme.colorScheme.onPrimary,
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddListScreen()),
          );
        },
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
