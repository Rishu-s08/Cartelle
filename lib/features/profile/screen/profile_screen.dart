import 'dart:async';

import 'package:cartelle/core/constants/route_constants.dart';
import 'package:cartelle/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Animation state for stats
  final List<bool> _showStats = [false, false, false];

  // Editable fields
  String name = "No Name";
  bool isEditingName = false;
  bool isDarkMode = false;

  // Stats
  int totalLists = 0;
  int totalReminders = 12; // TODO: Connect to reminders
  int totalLocations = 0;

  Timer? _timer1, _timer2, _timer3;

  @override
  void initState() {
    super.initState();
    _timer1 = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showStats[0] = true);
    });
    _timer2 = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showStats[1] = true);
    });
    _timer3 = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showStats[2] = true);
    });
  }

  @override
  void dispose() {
    _timer1?.cancel();
    _timer2?.cancel();
    _timer3?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("User not found. Please login again.")),
      );
    }
    name = user.name;
    totalLists = user.listIds?.length ?? 0;
    totalLocations = user.locations?.length ?? 0;
    final email = user.email;
    final joined = user.createdAt;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Section (non-editable)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 700),
                            opacity: 1,
                            child: Transform.scale(
                              scale: scale,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(
                                  'https://ui-avatars.com/api/'
                                  '?name=$name'
                                  '&size=120'
                                  '&background=0D8ABC'
                                  '&color=FFFFFF'
                                  '&rounded=true'
                                  '&bold=true',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blueGrey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Joined: ${joined.day}/${joined.month}/${joined.year}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Section
            Text(
              "Your Stats",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AnimatedSlide(
                        offset:
                            _showStats[0] ? Offset.zero : const Offset(-0.5, 0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _showStats[0] ? 1 : 0,
                          child: _buildStatCard(
                            "Lists",
                            totalLists,
                            Icons.list_alt,
                          ),
                        ),
                      ),
                      AnimatedSlide(
                        offset:
                            _showStats[1] ? Offset.zero : const Offset(0, 0.5),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _showStats[1] ? 1 : 0,
                          child: _buildStatCard(
                            "Reminders",
                            totalReminders,
                            Icons.alarm,
                          ),
                        ),
                      ),
                      AnimatedSlide(
                        offset:
                            _showStats[2] ? Offset.zero : const Offset(0.5, 0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _showStats[2] ? 1 : 0,
                          child: _buildStatCard(
                            "Locations",
                            totalLocations,
                            Icons.location_on,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Preferences Section
            Text(
              "Preferences",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                value: isDarkMode,
                title: const Text("Dark Mode"),
                onChanged: (val) {
                  setState(() => isDarkMode = val);
                  // TODO: Save preference in backend/local storage
                },
              ),
            ),
            const SizedBox(height: 24),

            // Info Section
            Text(
              "Info & Settings",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text("About"),
                    onTap: () => navigateToAboutPage(context),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text("Settings"),
                    onTap: () {
                      context.pushNamed(RouteConstants.profileSettingsRoute);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(180, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  // TODO: Firebase signOut
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Editable Field Widget
  Widget _buildEditableField({
    Key? key,
    required String label,
    required String value,
    required bool isEditing,
    required VoidCallback onEdit,
    required Function(String) onSave,
  }) {
    if (isEditing) {
      final controller = TextEditingController(text: value);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            autofocus: true,
            onSubmitted: (newValue) => onSave(newValue),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: () => onSave(controller.text),
            child: const Text("Save"),
          ),
        ],
      );
    } else {
      return ListTile(
        title: Text(value, style: TextStyle(overflow: TextOverflow.ellipsis)),
        subtitle: Text(label),
        trailing: IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
      );
    }
  }

  // Stats Card Widget
  Widget _buildStatCard(String title, int value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 100, minWidth: 80),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void navigateToAboutPage(BuildContext context) {
    context.pushNamed(RouteConstants.aboutRoute);
  }
}
