import 'package:cartelle/core/common/loader.dart';
import 'package:cartelle/core/constants/route_constants.dart';
import 'package:cartelle/core/errors/error_text.dart';
import 'package:cartelle/core/modals/list_model.dart';
import 'package:cartelle/features/add_list/controller/add_list_controller.dart';
import 'package:cartelle/features/home/controller/home_controller.dart';
import 'package:cartelle/features/home/widgets/list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShowListScreen extends ConsumerStatefulWidget {
  const ShowListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShowListScreenState();
}

class _ShowListScreenState extends ConsumerState<ShowListScreen> {
  void navigateToEditListScreen(ListModel list) {
    ref.read(listProvider.notifier).state = list;
    context.pushNamed(
      RouteConstants.editListRoute,
      pathParameters: {'listId': list.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(fetchListsProvider)
        .when(
          data: (data) {
            if (data.isEmpty) {
              return Center(
                child: Text(
                  'No lists found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            }
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final list = data[index];
                return ListCard(
                  itemsName: list.listItems,
                  title: list.listName,
                  location: list.location,
                  createdAt: list.createdAt,
                  items: list.completedItems,
                  listId: list.id,
                  onTap: () => navigateToEditListScreen(list),
                );
              },
            );
          },
          error: (error, stackTrace) {
            return ErrorText(error: error.toString());
          },
          loading: () => Loader(),
        );
  }
}
