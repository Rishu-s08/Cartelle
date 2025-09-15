import 'package:cartelle/features/home/screens/home_screen_organizer.dart';
import 'package:cartelle/features/home/screens/show_list_screen.dart';
import 'package:cartelle/features/location/screen/location_show_screen.dart';
import 'package:cartelle/features/profile/screen/profile_screen.dart';
import 'package:cartelle/features/reminder/screen/reminder_screen.dart';
import 'package:flutter/material.dart';

class Constants {
  final List<IconData> icons = [
    Icons.home,
    Icons.notification_add,
    Icons.location_on_rounded,
    Icons.person,
  ];

  final List pages = [
    HomeScreenOrganizer(),
    RemindersScreen(),
    LocationShowScreen(),
    ProfileScreen(),
  ];
}
