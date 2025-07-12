import 'package:cartelle/core/common/snackbar.dart';
import 'package:cartelle/core/modals/list_model.dart';
import 'package:cartelle/features/auth/controller/auth_controller.dart';
import 'package:cartelle/features/home/repository/home_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fetchListsProvider = StreamProvider((ref) {
  return ref.watch(homeControllerProvider).fetchLists();
});

final homeControllerProvider = Provider((ref) {
  return HomeController(ref.read(homeRepositoryProvider), ref);
});

class HomeController {
  final HomeRepository _homeRepository;
  final Ref _ref;
  HomeController(HomeRepository homeRepository, Ref ref)
    : _homeRepository = homeRepository,
      _ref = ref;

  Stream<List<ListModel>> fetchLists() {
    final userId = _ref.read(userProvider)!.uid;
    return _homeRepository.fetchLists(userId);
  }

  void checkedChanged(
    String listId,
    int index,
    Map<String, bool> completedItems,
    BuildContext context,
  ) async {
    final res = await _homeRepository.checkedChanged(
      listId,
      index,
      completedItems,
    );
    res.fold((l) => showSnackbar(context, l.message), (onRight) => null);
  }

  void deleteList(String listId, BuildContext context) async {
    final res = await _homeRepository.deleteList(listId);
    res.fold((l) => showSnackbar(context, l.message), (onRight) {
      showSnackbar(context, 'List deleted successfully');
    });
  }
}
