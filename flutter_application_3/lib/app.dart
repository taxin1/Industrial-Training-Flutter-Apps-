import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'main_page.dart';
import 'settings_page.dart';
import 'note_edit_page.dart';
import 'providers.dart';

class NoteApp extends ConsumerWidget {
  NoteApp({Key? key}) : super(key: key);

  // Create router as a static/stable instance
  static final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MainPage(
          toSettings: () => GoRouter.of(context).go('/settings'),
          fontSize: 18.0,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsPage(
          onClose: () => GoRouter.of(context).go('/'),
          fontSize: 18.0, // fallback, SettingsPage will use providers internally
          themeMode: ThemeMode.light, // fallback, SettingsPage will use providers internally
          onFontSizeChanged: (_) {},
          onThemeChanged: (_) {},
        ),
      ),
      GoRoute(
        path: '/edit',
        builder: (context, state) {
          return NoteEditPage(noteId: null); // For creating new notes
        },
      ),
      GoRoute(
        path: '/edit/:noteId',
        builder: (context, state) {
          final noteId = state.pathParameters['noteId'];
          return NoteEditPage(noteId: noteId); // For editing existing notes
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final fontSize = ref.watch(fontSizeProvider);

    return MaterialApp.router(
      title: 'Note Picker',
      routerConfig: _router,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: fontSize),
          bodyMedium: TextStyle(fontSize: fontSize),
          titleLarge: TextStyle(fontSize: fontSize + 4),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: fontSize),
          bodyMedium: TextStyle(fontSize: fontSize),
          titleLarge: TextStyle(fontSize: fontSize + 4),
        ),
      ),
      themeMode: themeMode,
    );
  }
}
