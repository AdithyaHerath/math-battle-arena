import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();

    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final backgroundColor = theme.colorScheme.background;
    final onBackground = theme.colorScheme.onBackground;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Audio',
                  style: TextStyle(
                    color: onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: surfaceColor.withOpacity(0.08),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      'Background music',
                      style: TextStyle(color: onBackground),
                    ),
                    subtitle: Text(
                      'Play music only on home and profile screens',
                      style: TextStyle(color: onBackground.withOpacity(0.7)),
                    ),
                    value: settingsVM.isMusicEnabled,
                    activeColor: Colors.amber,
                    onChanged: settingsVM.toggleMusic,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Theme',
                  style: TextStyle(
                    color: onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: surfaceColor.withOpacity(0.08),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        title: Text(
                          'Light theme',
                          style: TextStyle(color: onBackground),
                        ),
                        value: false,
                        groupValue: settingsVM.isDarkTheme,
                        activeColor: Colors.amber,
                        onChanged: (value) {
                          if (value != null) {
                            settingsVM.setDarkTheme(value);
                          }
                        },
                      ),
                      RadioListTile<bool>(
                        title: Text(
                          'Dark theme',
                          style: TextStyle(color: onBackground),
                        ),
                        value: true,
                        groupValue: settingsVM.isDarkTheme,
                        activeColor: Colors.amber,
                        onChanged: (value) {
                          if (value != null) {
                            settingsVM.setDarkTheme(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: surfaceColor.withOpacity(0.05),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      settingsVM.isDarkTheme
                          ? 'Dark theme is enabled. The app will use darker backgrounds and glowing accents.'
                          : 'Light theme is enabled. The app will use a brighter color palette.',
                      style: TextStyle(color: onBackground.withOpacity(0.75)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
