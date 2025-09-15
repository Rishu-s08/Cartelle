import 'package:cartelle/core/constants/firebase_constants.dart';
import 'package:cartelle/core/failure.dart';
import 'package:cartelle/core/modals/list_model.dart';
import 'package:cartelle/core/providers/firebase_providers.dart';
import 'package:cartelle/core/typedefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

final addListRepositoryProvider = Provider((ref) {
  return AddListRepository(
    firebaseFirestore: ref.read(firebaseFirestoreProvider),
  );
});

class AddListRepository {
  final FirebaseFirestore _firebaseFirestore;
  AddListRepository({required FirebaseFirestore firebaseFirestore})
    : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstants.usersCollection);

  CollectionReference get _lists =>
      _firebaseFirestore.collection(FirebaseConstants.listsCollection);

  FutureEither<ListModel> addList({
    required String listName,
    required List<String> listItems,
    required String location,
    required String userId,
    required String locationId,
  }) async {
    final list = ListModel(
      id: Uuid().v4(),
      listName: listName,
      listItems: listItems,
      location: location,
      createdAt: DateTime.now(),
      userId: userId,
      locationId: locationId,
      completedItems: Map.fromEntries(listItems.map((e) => MapEntry(e, false))),
    );
    try {
      await _lists.doc(list.id).set(list.toMap());
      await _users.doc(userId).update({
        'listIds': FieldValue.arrayUnion([list.id]),
      });
      return right(list);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<ListModel> getListDataById(String listId) async {
    try {
      final doc = await _lists.doc(listId).get();
      if (doc.exists) {
        final listData = ListModel.fromMap(doc.data() as Map<String, dynamic>);
        return right(listData);
      } else {
        return left(Failure('List not found'));
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateList({
    required String listName,
    required List<String> listItems,
    required String listlocationId,
    required String location,
    required String listId,
    required Map<String, bool> itemsMap,
  }) async {
    try {
      final list = await getListDataById(listId);
      if (list.isRight()) {
        final existingList = list.getOrElse((l) => throw "list not found");
        final updatedList = existingList.copyWith(
          listName: listName,
          listItems: listItems,
          locationId: listlocationId,
          completedItems: itemsMap,
          location: location,
        );
        await _lists.doc(listId).update(updatedList.toMap());
      }
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
