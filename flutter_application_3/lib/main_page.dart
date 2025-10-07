import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'package:go_router/go_router.dart';

class MainPage extends ConsumerWidget {
  final VoidCallback toSettings;

  MainPage({required this.toSettings, required double fontSize});

  void _showDeleteDialog(BuildContext context, String noteId, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(notesProvider.notifier).deleteNote(noteId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: TextStyle(fontSize: fontSize + 4), // Slightly larger for app bar
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: toSettings,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => GoRouter.of(context).go('/edit'),
      ),
      body: notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: TextStyle(fontSize: fontSize + 2, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first note',
                    style: TextStyle(fontSize: fontSize, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                // Split content into title and body
                final parts = note.content.split('\n\n');
                final title = parts.isNotEmpty ? parts[0] : 'Untitled';
                final preview = parts.length > 1 ? parts[1] : '';
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: note.imagePath != null
                        ? const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.image, color: Colors.white),
                          )
                        : const CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.note, color: Colors.white),
                          ),
                    title: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      ),
                    ),
                    subtitle: preview.isNotEmpty
                        ? Text(
                            preview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: fontSize - 2,
                            ),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => GoRouter.of(context).go('/edit/${note.id}'),
                          tooltip: 'Edit note',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context, note.id, ref),
                          tooltip: 'Delete note',
                        ),
                      ],
                    ),
                    onTap: () => GoRouter.of(context).go('/edit/${note.id}'),
                  ),
                );
              },
            ),
    );
  }
}
