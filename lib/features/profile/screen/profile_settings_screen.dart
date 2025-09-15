import 'package:cartelle/core/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  ThemeMode themeMode = ThemeMode.system;
  String language = 'English';
  bool reminderNotificationsEnabled = true;
  bool locationNotificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ACCOUNT SECTION
          _sectionTitle("Account"),
          _settingsCard(
            context,
            children: [
              _settingsTile(
                icon: Icons.person_outline,
                title: "Edit Profile",
                onTap: () {
                  context.pushNamed(RouteConstants.editProfileRoute);
                },
              ),
              _settingsTile(
                icon: Icons.lock_outline,
                title: "Change Password",
                onTap: () {},
              ),
            ],
          ),

          // NOTIFICATIONS SECTION
          _sectionTitle("Notifications"),
          _settingsCard(
            context,
            children: [
              _switchTile(
                icon: Icons.notifications_active_outlined,
                title: "Enable Reminders",
                value: reminderNotificationsEnabled,
                onChanged: (v) {
                  setState(() {
                    reminderNotificationsEnabled = v;
                  });
                },
              ),
              _switchTile(
                icon: Icons.location_on_outlined,
                title: "Location Alerts",
                value: locationNotificationsEnabled,
                onChanged: (v) {
                  setState(() {
                    locationNotificationsEnabled = v;
                  });
                },
              ),
            ],
          ),

          // PREFERENCES SECTION
          _sectionTitle("Preferences"),
          _settingsCard(
            context,
            children: [
              _settingsTile(
                icon: Icons.palette_outlined,
                title: "Theme",
                subtitle:
                    themeMode == ThemeMode.system
                        ? "System Default"
                        : themeMode == ThemeMode.light
                        ? "Light"
                        : "Dark",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Select Theme'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<ThemeMode>(
                              title: const Text('Light'),
                              value: ThemeMode.light,
                              groupValue: themeMode,
                              onChanged: (value) {
                                setState(() => themeMode = value!);
                                Navigator.pop(context);
                              },
                            ),
                            RadioListTile<ThemeMode>(
                              title: const Text('Dark'),
                              value: ThemeMode.dark,
                              groupValue: themeMode,
                              onChanged: (value) {
                                setState(() => themeMode = value!);
                                Navigator.pop(context);
                              },
                            ),
                            RadioListTile<ThemeMode>(
                              title: const Text('System Default'),
                              value: ThemeMode.system,
                              groupValue: themeMode,
                              onChanged: (value) {
                                setState(() => themeMode = value!);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              _settingsTile(
                icon: Icons.language_outlined,
                title: "Language",
                subtitle: language,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Select Language'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<String>(
                              title: const Text('English'),
                              value: 'English',
                              groupValue: language,
                              onChanged: (value) {
                                setState(() => language = value!);
                                Navigator.pop(context);
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Hindi'),
                              value: 'Hindi',
                              groupValue: language,
                              onChanged: (value) {
                                setState(() => language = value!);
                                Navigator.pop(context);
                              },
                            ),
                            // Add more languages here
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),

          // PRIVACY SECTION
          _sectionTitle("Privacy"),
          _settingsCard(
            context,
            children: [
              _settingsTile(
                icon: Icons.delete_outline,
                title: "Clear All Data",
                onTap: () {},
              ),
              _settingsTile(
                icon: Icons.logout,
                title: "Logout",
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _settingsCard(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.blueGrey),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
    );
  }
}
