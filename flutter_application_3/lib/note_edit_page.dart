import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'providers.dart';
import 'package:go_router/go_router.dart';

class NoteEditPage extends ConsumerStatefulWidget {
  final String? noteId;

  const NoteEditPage({super.key, this.noteId});

  @override
  ConsumerState<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends ConsumerState<NoteEditPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;
  Uint8List? _webImage;
  bool _isInitialized = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    titleController.addListener(_onTextChanged);
    contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    titleController.removeListener(_onTextChanged);
    contentController.removeListener(_onTextChanged);
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  void _initializeNote(List<Note> notes) {
    if (!_isInitialized && widget.noteId != null) {
      try {
        final note = notes.firstWhere((n) => n.id == widget.noteId);
        final parts = note.content.split('\n\n');
        if (parts.length >= 2) {
          titleController.text = parts[0];
          contentController.text = parts.sublist(1).join('\n\n');
        } else {
          titleController.text = 'Untitled';
          contentController.text = note.content;
        }
        _selectedImagePath = note.imagePath;
        _hasUnsavedChanges = false;
      } catch (e) {
        // Note not found, treat as new note
      }
      _isInitialized = true;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          _hasUnsavedChanges = true;
        });
        
        if (image.path.startsWith('blob:')) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImagePath = null;
      _webImage = null;
      _hasUnsavedChanges = true;
    });
  }

  Future<bool> _showSaveDialog() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('discard'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('save'),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    
    if (result == 'save') {
      saveNote();
      return true;
    } else if (result == 'discard') {
      return true;
    } else {
      return false;
    }
  }

  void saveNote() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    
    if (title.isEmpty && content.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add some content to your note')),
        );
      }
      return;
    }

    final noteTitle = title.isEmpty ? 'Untitled' : title;
    final fullContent = content.isEmpty ? noteTitle : '$noteTitle\n\n$content';

    if (widget.noteId == null) {
      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: fullContent,
        imagePath: _selectedImagePath,
      );
      ref.read(notesProvider.notifier).addNote(newNote);
    } else {
      final updatedNote = Note(
        id: widget.noteId!,
        content: fullContent,
        imagePath: _selectedImagePath,
      );
      ref.read(notesProvider.notifier).updateNote(updatedNote);
    }

    setState(() {
      _hasUnsavedChanges = false;
    });

    if (mounted) {
      GoRouter.of(context).go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final isNew = widget.noteId == null;
    
    _initializeNote(notes);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        final shouldPop = await _showSaveDialog();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isNew ? 'Create Note' : 'Edit Note'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldLeave = await _showSaveDialog();
              if (shouldLeave && mounted) {
                GoRouter.of(context).go('/');
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: saveNote,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter note title...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                style: TextStyle(
                  fontSize: fontSize + 2,
                  fontWeight: FontWeight.bold,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: contentController,
                maxLines: 12,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Start writing your note...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
                style: TextStyle(fontSize: fontSize),
                textCapitalization: TextCapitalization.sentences,
              ),
              
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.image, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Image Attachment',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (_selectedImagePath != null)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: _removeImage,
                              tooltip: 'Remove image',
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      if (_selectedImagePath != null) ...[
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _webImage != null
                                ? Image.memory(
                                    _webImage!,
                                    fit: BoxFit.cover,
                                  )
                                : _selectedImagePath!.startsWith('http')
                                    ? Image.network(
                                        _selectedImagePath!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(Icons.error),
                                            ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text(
                            _selectedImagePath != null ? 'Change Image' : 'Add Image',
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: saveNote,
                icon: const Icon(Icons.save),
                label: Text(
                  isNew ? 'Create Note' : 'Update Note',
                  style: TextStyle(fontSize: fontSize),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}