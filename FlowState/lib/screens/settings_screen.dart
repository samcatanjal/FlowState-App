import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/color_picker_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 20,
        ), // Extra space for bottom nav
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8), // Small top margin
              const Text(
                'Appearance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text(
                          'Toggle between light and dark theme',
                        ),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) => themeProvider.toggleTheme(value),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.palette),
                        title: const Text('Primary Color'),
                        subtitle: Text(
                          'Current: #${themeProvider.primaryColor.value.toRadixString(16)}',
                        ),
                        onTap:
                            () => showDialog(
                              context: context,
                              builder: (_) => const ColorPickerDialog(),
                            ),
                      ),
                      ListTile(
                        title: Text(
                          'Vibration Duration (ms)',
                          style: GoogleFonts.poppins(),
                        ),
                        subtitle: Slider(
                          value: themeProvider.vibrationDuration.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 10,
                          label: '${themeProvider.vibrationDuration}ms',
                          onChanged: (value) {
                            themeProvider.setVibrationDuration(value.toInt());
                          },
                        ),
                        trailing: Text(
                          '${themeProvider.vibrationDuration}ms',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // const Text(
              //   'Preferences',
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 8),
              // Card(
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Column(
              //       children: [
              //         ListTile(
              //           leading: const Icon(Icons.notifications),
              //           title: const Text('Notifications'),
              //           subtitle: const Text('Manage notification preferences'),
              //           onTap: () {},
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
