// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cartelle/core/common/snackbar.dart';
import 'package:cartelle/core/modals/list_model.dart';
import 'package:cartelle/features/add_list/repository/add_list_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final listProvider = StateProvider<ListModel?>((ref) => null);

final addListControllerProvider =
    StateNotifierProvider<AddListController, bool>((ref) {
      return AddListController(
        addListRepository: ref.read(addListRepositoryProvider),
        ref: ref,
      );
    });

class AddListController extends StateNotifier<bool> {
  final AddListRepository _addListRepository;
  final Ref _ref;
  AddListController({
    required Ref ref,
    required AddListRepository addListRepository,
  }) : _addListRepository = addListRepository,
       _ref = ref,
       super(false);

  void addList(
    String listName,
    List<String> listItems,
    String location,
    String userId,
    String locationId,
    BuildContext context,
  ) async {
    state = true;
    final res = await _addListRepository.addList(
      listName: listName,
      listItems: listItems,
      location: location,
      userId: userId,
      locationId: locationId,
    );
    state = false;
    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => showSnackbar(context, "List uploaded successfully!"),
    );
  }

  void getListDataById(String listId, BuildContext context) async {
    final res = await _addListRepository.getListDataById(listId);
    return res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => _ref.read(listProvider.notifier).update((state) => r),
    );
  }

  void updateList({
    required String listName,
    required List<String> listItems,
    required String location,
    required Map<String, bool> itemsMap,
    required String listId,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _addListRepository.updateList(
      listName: listName,
      listItems: listItems,
      itemsMap: itemsMap,
      location: location,
      listId: listId,
    );
    state = false;
    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => showSnackbar(context, "List updated successfully!"),
    );
  }
}
