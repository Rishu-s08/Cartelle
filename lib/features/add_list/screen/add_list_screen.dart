import 'package:cartelle/core/common/loader.dart';
import 'package:cartelle/features/add_list/controller/add_list_controller.dart';
import 'package:cartelle/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddListScreen extends ConsumerStatefulWidget {
  const AddListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddListScreenState();
}

class _AddListScreenState extends ConsumerState<AddListScreen> {
  final TextEditingController _listNameController = TextEditingController();
  final List<TextEditingController> _itemControllers = [
    TextEditingController(),
  ];
  final List<UniqueKey> _itemKeys = [UniqueKey()];
  String? _selectedLocation;
  final List<String> _locations = [
    'Big Bazaar',
    'Reliance Fresh',
    'Add New Location',
  ];

  void _addNewItemField() {
    setState(() {
      _itemControllers.add(TextEditingController());
      _itemKeys.add(UniqueKey());
    });
  }

  void _saveList() {
    // Implement actual save logic
    final listName = _listNameController.text.trim();
    final location = "text";
    final items =
        _itemControllers
            .map((c) => c.text.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    if (listName.isEmpty || items.isEmpty || _selectedLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }
    final user = ref.watch(userProvider)!;

    ref
        .read(addListControllerProvider.notifier)
        .addList(listName, items, location, user.uid, "test", context);
    context.pop();
  }

  @override
  void dispose() {
    _listNameController.dispose();
    for (final c in _itemControllers) {
      c.dispose();
    }
    _itemKeys.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(addListControllerProvider);
    return isLoading
        ? Loader()
        : Scaffold(
          appBar: AppBar(title: const Text('Create Shopping List')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _listNameController,
                    decoration: const InputDecoration(
                      labelText: 'List Title',

                      prefixIcon: Icon(Icons.edit_note),
                    ),
                    maxLength: 30,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    onChanged: (val) {
                      setState(() => _selectedLocation = val);
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
                        key: _itemKeys[index],
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
                                                final controller =
                                                    _itemControllers.removeAt(
                                                      index,
                                                    );
                                                controller.dispose();
                                                _itemKeys.removeAt(index);
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
              onPressed: _saveList,
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
