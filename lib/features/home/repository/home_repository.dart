import 'package:cartelle/core/constants/firebase_constants.dart';
import 'package:cartelle/core/failure.dart';
import 'package:cartelle/core/modals/list_model.dart';
import 'package:cartelle/core/modals/reminder_model.dart';
import 'package:cartelle/core/providers/firebase_providers.dart';
import 'package:cartelle/core/typedefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final homeRepositoryProvider = Provider((ref) {
  return HomeRepository(ref.read(firebaseFirestoreProvider));
});

class HomeRepository {
  final FirebaseFirestore _firestore;
  HomeRepository(FirebaseFirestore firestore) : _firestore = firestore;

  CollectionReference get listsCollection =>
      _firestore.collection(FirebaseConstants.listsCollection);

  CollectionReference get remindersCollection =>
      _firestore.collection(FirebaseConstants.remindersCollection);

  Stream<List<ListModel>> fetchLists(String userId) {
    return listsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshots) =>
              snapshots.docs
                  .map(
                    (doc) =>
                        ListModel.fromMap(doc.data() as Map<String, dynamic>),
                  )
                  .toList(),
        );
  }

  Stream<List<ReminderModel>> fetchReminders(String userId) {
    return remindersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshots) =>
              snapshots.docs
                  .map(
                    (doc) => ReminderModel.fromMap(
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
        );
  }

  FutureVoid checkedChanged(
    String listId,
    int index,
    Map<String, bool> completedItems,
  ) async {
    try {
      await listsCollection.doc(listId).update({
        'completedItems': completedItems,
      });
      return right(null);
    } catch (e) {
      return left(Failure("something went wrong while updating the list"));
    }
  }

  FutureVoid deleteList(String listId) async {
    try {
      await listsCollection.doc(listId).delete();
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure("something went wrong while deleting the list"));
    }
  }

  FutureVoid deleteReminder(String reminderId) async {
    try {
      await remindersCollection.doc(reminderId).delete();
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure("something went wrong while deleting the reminder"));
    }
  }
}
