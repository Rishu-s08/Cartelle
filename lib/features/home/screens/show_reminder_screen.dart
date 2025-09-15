import 'package:cartelle/core/sevices/notification_service.dart';
import 'package:cartelle/features/home/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ShowReminderScreen extends ConsumerStatefulWidget {
  const ShowReminderScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShowReminderScreenState();
}

class _ShowReminderScreenState extends ConsumerState<ShowReminderScreen> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    NotificationService.scheduleReminder(
      id: Uuid().v4(),
      title: "Scheduled Notification",
      body: "This should appear 30 seconds later ✅",
      scheduledDate: now.add(Duration(seconds: 5)),
    );
    NotificationService.testNotification();
    NotificationService.testImmediateNotification();
    return Scaffold(
      body: ref
          .watch(fetchRemindersProvider)
          .when(
            data: (reminders) {
              if (reminders.isEmpty) {
                return const Center(
                  child: Text(
                    "No reminders yet.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: reminders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  final formattedDate = DateFormat(
                    "EEE, MMM d • hh:mm a",
                  ).format(reminder.dateTime);
                  // final formattedDate =
                  //     "${reminder.dateTime.day}/${reminder.dateTime.month} "
                  //     "${reminder.dateTime.hour}:${reminder.dateTime.minute.toString().padLeft(2, '0')}";

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      title: Text(
                        reminder.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref
                              .read(homeControllerProvider)
                              .deleteReminder(reminder.id, context);
                        },
                      ),
                    ),
                  );
                },
              );
            },
            error: (error, _) => Center(child: Text("Error: $error")),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
    );
  }
}
