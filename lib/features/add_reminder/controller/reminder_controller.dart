// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cartelle/core/common/snackbar.dart';
import 'package:cartelle/core/modals/reminder_model.dart';
import 'package:cartelle/core/sevices/notification_service.dart';
import 'package:cartelle/features/add_reminder/repository/reminder_repository.dart';
import 'package:cartelle/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reminderProvider = StateProvider<ReminderModel?>((ref) => null);

final reminderControllerProvider =
    StateNotifierProvider<ReminderController, bool>((ref) {
      return ReminderController(
        reminderRepository: ref.read(reminderRepositoryProvider),
        ref: ref,
      );
    });

class ReminderController extends StateNotifier<bool> {
  final ReminderRepository _reminderRepository;
  final Ref _ref;
  ReminderController({
    required Ref ref,
    required ReminderRepository reminderRepository,
  }) : _reminderRepository = reminderRepository,
       _ref = ref,
       super(false);

  void addReminder({
    required String title,
    required DateTime dateTime,
    required BuildContext context,
  }) async {
    state = true;
    final userId = _ref.read(userProvider)!.uid;
    final res = await _reminderRepository.addReminder(
      title: title,
      dateTime: dateTime,
      userId: userId,
    );

    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      NotificationService.scheduleReminder(
        id: r.id,
        title: "Reminder: ${r.title}",
        body: "⏰ It's time!",
        scheduledDate: r.dateTime,
      );
      NotificationService.testImmediateNotification();

      NotificationService.testNotification();

      // NotificationService.testImmediateNotification();
      showSnackbar(context, "Reminder uploaded successfully!");
    });
  }

  void getReminderDataById(String reminderId, BuildContext context) async {
    final res = await _reminderRepository.getReminderDataById(reminderId);
    return res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => _ref.read(reminderProvider.notifier).update((state) => r),
    );
  }

  void updateReminder({
    required String reminderId,
    required String title,
    required DateTime dateTime,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _reminderRepository.updateReminder(
      reminderId: reminderId,
      reminderName: title,
      reminderDateTime: dateTime,
    );
    state = false;
    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => showSnackbar(context, "Reminder updated successfully!"),
    );
  }
}
