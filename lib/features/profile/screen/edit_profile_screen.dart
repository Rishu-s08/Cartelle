import 'package:cartelle/core/common/snackbar.dart';
import 'package:cartelle/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Replace with your actual user provider value
    final user = ref.read(userProvider);
    _nameController = TextEditingController(text: user?.name ?? "");
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final newName = _nameController.text.trim();

      // Call your update function here
      ref
          .read(authControllerProvider.notifier)
          .updateUserName(newName, context);

      // Update local provider state
      ref.read(userProvider.notifier).update((user) {
        return user?.copyWith(name: newName);
      });
      context.pop();
      showSnackbar(context, "Name updated successfully");
    } catch (e) {
      if (mounted) {
        showSnackbar(context, "Error: $e");
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  'https://ui-avatars.com/api/'
                  '?name=${_nameController.text}'
                  '&size=120'
                  '&background=0D8ABC'
                  '&color=FFFFFF'
                  '&rounded=true'
                  '&bold=true',
                ),
              ),

              const SizedBox(height: 30),

              // Name Input
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Name cannot be empty";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
