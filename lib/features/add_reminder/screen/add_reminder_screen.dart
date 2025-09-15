import 'package:cartelle/core/common/snackbar.dart';
import 'package:cartelle/features/add_reminder/controller/reminder_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  const AddReminderScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  final _titleController = TextEditingController();
  DateTime? _selectedDateTime;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _saveReminder() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showSnackbar(context, "Please enter a title for the reminder.");
      return;
    }

    // Later: Save reminder to DB or state provider
    if (_selectedDateTime == null) {
      showSnackbar(context, "Please select date and time for the reminder.");
      return;
    }

    ref
        .read(reminderControllerProvider.notifier)
        .addReminder(
          title: title,
          dateTime: _selectedDateTime!,
          context: context,
        );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Reminder"),
        centerTitle: true,
        backgroundColor: const Color(0xFF9E6950),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      backgroundColor: const Color(0xFFFDF8F5),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Title Input
            Card(
              elevation: 4,
              color: const Color(0xFFE0D5D3),
              shadowColor: Colors.brown.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Reminder Title",
                    prefixIcon: Icon(Icons.edit_note, color: Color(0xFF9E6950)),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Date & Time Picker
            Card(
              elevation: 4,
              shadowColor: Colors.brown.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                leading: const Icon(Icons.alarm, color: Color(0xFF9E6950)),
                title: Text(
                  _selectedDateTime == null
                      ? "Pick Date & Time"
                      : DateFormat(
                        "EEE, MMM d • hh:mm a",
                      ).format(_selectedDateTime!),
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        _selectedDateTime == null
                            ? Colors.brown.shade300
                            : Colors.brown.shade900,
                    fontWeight:
                        _selectedDateTime == null
                            ? FontWeight.w400
                            : FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: _pickDateTime,
              ),
            ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveReminder,
                icon: const Icon(Icons.save),
                label: const Text("Save Reminder"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9E6950),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 4,
                  shadowColor: Colors.brown.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
