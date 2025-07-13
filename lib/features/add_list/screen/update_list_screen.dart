import 'package:cartelle/core/common/loader.dart';
import 'package:cartelle/core/modals/list_model.dart';
import 'package:cartelle/features/add_list/controller/add_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UpdateListScreen extends ConsumerStatefulWidget {
  final String listId;

  const UpdateListScreen({super.key, required this.listId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UpdateListScreenState();
}

class _UpdateListScreenState extends ConsumerState<UpdateListScreen> {
  late TextEditingController titleController;
  late List<TextEditingController> _itemControllers;
  late ListModel originalList;
  late ListModel localList;
  late String selectedLocation;

  @override
  void initState() {
    super.initState();
    originalList = ref.read(listProvider)!;
    localList = originalList.copyWith();
    selectedLocation = localList.location;
    titleController = TextEditingController(text: localList.listName);
    _itemControllers =
        localList.listItems
            .map((item) => TextEditingController(text: item))
            .toList();
  }

  // final List<UniqueKey> _itemKeys = [UniqueKey()];

  final List<String> _locations = [
    'Big Bazaar',
    'Reliance Fresh',
    'D-Mart',
    'text',
    'Add New Location',
  ];

  void _addNewItemField() {
    setState(() {
      _itemControllers.add(TextEditingController());
      // _itemKeys.add(UniqueKey());
    });
  }

  Map<String, bool> generateUpdatedItemsMap({
    required List<String> newItems,
    required Map<String, bool> oldItemsMap,
  }) {
    final updatedMap = <String, bool>{};

    for (final item in newItems) {
      updatedMap[item] = oldItemsMap[item] ?? false;
    }
    return updatedMap;
  }

  void _updateList(ListModel list) {
    // Implement actual save logic
    final listName = titleController.text.trim();
    final location = "text";
    final items =
        _itemControllers
            .map((c) => c.text.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    if (listName.isEmpty || items.isEmpty || selectedLocation.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    ref
        .read(addListControllerProvider.notifier)
        .updateList(
          itemsMap: generateUpdatedItemsMap(
            newItems: items,
            oldItemsMap: localList.completedItems,
          ),
          listName: listName,
          listItems: items,
          location: location,
          listId: list.id,
          context: context,
        );
    context.pop();
  }

  @override
  void dispose() {
    titleController.dispose();
    for (final c in _itemControllers) {
      c.dispose();
    }
    // _itemKeys.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final list = ref.watch(listProvider)!;
    final isLoading = ref.watch(addListControllerProvider);
    return isLoading
        ? Loader()
        : Scaffold(
          appBar: AppBar(title: const Text('Update Buying List')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'List Title',

                      prefixIcon: Icon(Icons.edit_note),
                    ),
                    maxLength: 30,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: localList.location,
                    onChanged: (val) {
                      setState(() => selectedLocation = val!);
                    },
                    items:
                        _locations.map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Select Location',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Items:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _itemControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.circle_outlined, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _itemControllers[index],
                                decoration: InputDecoration(
                                  hintText: 'Item ${index + 1}',
                                  suffixIcon: IconButton(
                                    onPressed:
                                        _itemControllers.length == 1
                                            ? null
                                            : () {
                                              setState(() {
                                                // _itemKeys.removeAt(index);
                                                localList.completedItems.remove(
                                                  localList.completedItems.keys
                                                      .toList()[index],
                                                );
                                                localList.listItems.removeAt(
                                                  index,
                                                );
                                                final controller =
                                                    _itemControllers.removeAt(
                                                      index,
                                                    );
                                                controller.dispose();
                                              });
                                            },
                                    icon: const Icon(
                                      Icons.delete_rounded,
                                      color: Color.fromARGB(255, 186, 30, 19),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: _addNewItemField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _updateList(localList),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Save List'),
            ),
          ),
        );
  }
}
