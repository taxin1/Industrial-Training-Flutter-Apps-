import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ============== MODEL ==============
class Note {
  final String id;
  final String content;
  final String? imagePath;

  Note({
    required this.id,
    required this.content,
    this.imagePath,
  });

  Note copyWith({String? content, String? imagePath}) {
    return Note(
      id: id,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    content: json['content'],
    imagePath: json['imagePath'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'imagePath': imagePath,
  };
}

// ============ NOTES LOGIC =============
class NotesNotifier extends Notifier<List<Note>> {
  @override
  List<Note> build() {
    loadNotes();
    return [];
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesData = prefs.getStringList('notes') ?? [];
    state = notesData.map((e) => Note.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesData = state.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList('notes', notesData);
  }

  Future<void> addNote(Note note) async {
    state = [...state, note];
    await saveNotes();
  }

  Future<void> updateNote(Note updatedNote) async {
    state = [
      for (final note in state)
        if (note.id == updatedNote.id) updatedNote else note
    ];
    await saveNotes();
  }

  Future<void> deleteNote(String id) async {
    state = state.where((note) => note.id != id).toList();
    await saveNotes();
  }
}

final notesProvider = NotifierProvider<NotesNotifier, List<Note>>(() {
  return NotesNotifier();
});

// ============ FONT SIZE =============
class FontSizeNotifier extends Notifier<double> {
  @override
  double build() {
    _loadSavedFontSize();
    return 18.0; // Initial default while loading
  }

  Future<void> _loadSavedFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSize = prefs.getDouble('fontSize') ?? 18.0;
    state = savedSize;
  }

  void updateFontSize(double size) async {
    state = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
  }
}

final fontSizeProvider = NotifierProvider<FontSizeNotifier, double>(() {
  return FontSizeNotifier();
});

// ============ THEME MODE =============
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadSavedThemeMode();
    return ThemeMode.light; // Initial default while loading
  }

  Future<void> _loadSavedThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void updateTheme(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});
