import 'package:cartelle/core/modals/list_model.dart';
import 'package:cartelle/core/modals/location_model.dart';
import 'package:cartelle/core/modals/reminder_model.dart';
import 'package:cartelle/features/add_list/controller/add_list_controller.dart';
import 'package:cartelle/features/home/controller/home_controller.dart';
import 'package:cartelle/features/location/controller/location_controller.dart';
import 'package:cartelle/theme/app_theme.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late List<ListModel> _locationReminders;
  late List<ReminderModel> _timeReminders;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _locationReminders =
        ref
            .watch(fetchListsProvider)
            .whenOrNull(
              data: (data) => data,
              loading: () => [],
              error: (error, stack) => [],
            ) ??
        [];

    _timeReminders =
        ref
            .watch(fetchRemindersProvider)
            .whenOrNull(
              data: (data) => data,
              loading: () => [],
              error: (error, stack) => [],
            ) ??
        [];
    int activeIndex = 0;
    final PageController _pageController = PageController();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reminders",
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontSize: 26,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomSlidingSegmentedControl<int>(
              initialValue: activeIndex,
              children: {
                0: Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                1: Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Timer",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildReminderList(_locationReminders, theme, isTime: false),
                _buildTimeReminderList(_timeReminders, theme, isTime: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderList(
    List<ListModel> reminders,
    ThemeData theme, {
    required bool isTime,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(
                isTime ? LucideIcons.clock : LucideIcons.mapPin,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(reminder.listName),
            subtitle: Text(
              isTime ? "⏰ ${reminder.listName}" : "📍 ${reminder.location}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            trailing: Switch(
              value: true,
              onChanged: (val) {
                setState(() => val = false);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeReminderList(
    List<ReminderModel> reminders,
    ThemeData theme, {
    required bool isTime,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        final formattedDate = DateFormat(
          "EEE, MMM d • hh:mm a",
        ).format(reminder.dateTime);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(
                isTime ? LucideIcons.clock : LucideIcons.mapPin,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(reminder.title),
            subtitle: Text(
              "⏰ ${formattedDate}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            trailing: Switch(
              value: true,
              onChanged: (val) {
                setState(() => val = false);
              },
            ),
          ),
        );
      },
    );
  }
}
