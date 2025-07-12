import 'dart:async';

import 'package:cartelle/features/home/controller/home_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListCard extends ConsumerStatefulWidget {
  final String title;
  final String location;
  final String listId;
  final List<String> itemsName;
  final Map<String, bool> items;
  final DateTime createdAt;
  final VoidCallback onTap;

  const ListCard({
    super.key,
    required this.title,
    required this.itemsName,
    required this.listId,
    required this.location,
    required this.items,
    required this.createdAt,
    required this.onTap,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ListCardState();
}

class _ListCardState extends ConsumerState<ListCard> {
  Timer? _debounce;
  late Map<String, bool> localMap;
  late List<String> itemsName;

  @override
  void initState() {
    super.initState();
    localMap = Map<String, bool>.from(widget.items);
    itemsName = widget.itemsName;
  }

  @override
  void didUpdateWidget(covariant ListCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    localMap = Map<String, bool>.from(widget.items);
    itemsName = widget.itemsName;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void checkedChange(int index, bool value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref
          .read(homeControllerProvider)
          .checkedChanged(widget.listId, index, localMap, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final itemsName = localMap.keys.toList();

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha((0.1 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed:
                      () => ref
                          .read(homeControllerProvider)
                          .deleteList(widget.listId, context),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Location and Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.location,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${widget.createdAt.day}/${widget.createdAt.month}/${widget.createdAt.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Items List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemsName.length,
              itemBuilder: (context, index) {
                final item = itemsName[index];
                final isChecked = localMap[item] ?? false;

                return CheckboxListTile(
                  value: isChecked,
                  visualDensity: const VisualDensity(vertical: -4),
                  checkboxShape: const CircleBorder(),
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (val) {
                    setState(() {
                      localMap[item] = !isChecked;
                    });
                    checkedChange(index, !isChecked);
                  },
                  title:
                      isChecked
                          ? Text(
                            item,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 2,
                            ),
                          )
                          : Text(item),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
