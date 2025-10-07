import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';  // contains fontSizeProvider, themeModeProvider

class SettingsPage extends ConsumerWidget {
  final VoidCallback onClose;

  SettingsPage({
    required this.onClose,
    required Null Function(dynamic darkMode) onThemeChanged, // still accepted but not used internally
    required Null Function(dynamic value) onFontSizeChanged, // still accepted but not used internally
    required ThemeMode themeMode,
    required double fontSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: fontSize + 4),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onClose),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.text_fields),
                const SizedBox(width: 8),
                Text(
                  'Font Size: ${fontSize.toInt()}',
                  style: TextStyle(fontSize: fontSize),
                ),
                Expanded(
                  child: Slider(
                    min: 12,
                    max: 32,
                    value: fontSize,
                    onChanged: (value) {
                      // Update Riverpod state directly
                      ref.read(fontSizeProvider.notifier).updateFontSize(value);
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.brightness_6),
                const SizedBox(width: 8),
                Text(
                  'Dark Mode',
                  style: TextStyle(fontSize: fontSize),
                ),
                Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    // Update Riverpod state for theme mode
                    ref.read(themeModeProvider.notifier).updateTheme(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
