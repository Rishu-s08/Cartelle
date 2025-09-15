import 'package:cartelle/core/constants/firebase_constants.dart';
import 'package:cartelle/core/failure.dart';
import 'package:cartelle/core/modals/list_model.dart';
import 'package:cartelle/core/modals/reminder_model.dart';
import 'package:cartelle/core/providers/firebase_providers.dart';
import 'package:cartelle/core/typedefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

final reminderRepositoryProvider = Provider((ref) {
  return ReminderRepository(
    firebaseFirestore: ref.read(firebaseFirestoreProvider),
  );
});

class ReminderRepository {
  final FirebaseFirestore _firebaseFirestore;
  ReminderRepository({required FirebaseFirestore firebaseFirestore})
    : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _reminders =>
      _firebaseFirestore.collection(FirebaseConstants.remindersCollection);

  FutureEither<ReminderModel> addReminder({
    required String title,
    required DateTime dateTime,
    required String userId,
  }) async {
    final reminder = ReminderModel(
      title: title,
      dateTime: dateTime,
      createdAt: DateTime.now(),
      id: Uuid().v4(),
      userId: userId,
      isActive: true,
    );
    try {
      await _reminders.doc(reminder.id).set(reminder.toMap());
      return right(reminder);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<ReminderModel> getReminderDataById(String reminderId) async {
    try {
      final doc = await _reminders.doc(reminderId).get();
      if (doc.exists) {
        final reminderData = ReminderModel.fromMap(
          doc.data() as Map<String, dynamic>,
        );
        return right(reminderData);
      } else {
        return left(Failure('Reminder not found'));
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateReminder({
    required String reminderName,
    required DateTime reminderDateTime,
    required String reminderId,
  }) async {
    try {
      final reminder = await getReminderDataById(reminderId);
      if (reminder.isRight()) {
        final existingReminder = reminder.getOrElse(
          (r) => throw "reminder not found",
        );
        final updatedReminder = existingReminder.copyWith(
          title: reminderName,
          dateTime: reminderDateTime,
        );
        await _reminders.doc(reminderId).update(updatedReminder.toMap());
      }
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
