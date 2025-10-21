
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart' as mime;
import 'package:rive/rive.dart';

import '../models/chat_message.dart';
import '../providers/providers.dart';
import 'settings_screen.dart';

// Simple basename helper that works on web and desktop paths
String _basenamePath(String s) {
  final idx1 = s.lastIndexOf('/');
  final idx2 = s.lastIndexOf('\\');
  final idx = idx1 > idx2 ? idx1 : idx2;
  return idx >= 0 ? s.substring(idx + 1) : s;
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  List<Attachment> _pendingAttachments = [];
  bool _stickToBottom = true; // whether we should keep auto-scrolling
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScale;
  late AnimationController _attachmentController;
  late AnimationController _messageAnimationController;
  String? _previousThreadId;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _sendButtonScale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeInOut),
    );
    _attachmentController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _messageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1800), // Reduced from 3600ms to 1800ms (faster)
      vsync: this,
    );

    // Track whether user is near the bottom to decide auto-scroll during streaming
    _scrollCtrl.addListener(() {
      if (!_scrollCtrl.hasClients) return;
      final pos = _scrollCtrl.position;
      final distanceFromBottom = (pos.maxScrollExtent - pos.pixels);
      _stickToBottom = distanceFromBottom < 120; // threshold
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    _inputFocusNode.dispose();
    _sendButtonController.dispose();
    _attachmentController.dispose();
    _messageAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.any,
    );
    if (result == null) return;
    final files = result.files;
    setState(() {
      _pendingAttachments = files.map((f) {
        final pathOrName = f.path ?? f.name;
        final mt = f.extension != null
            ? mime.lookupMimeType('x.${f.extension}')
            : mime.lookupMimeType(f.name);
        return Attachment(path: pathOrName, mimeType: mt, size: f.size, bytes: f.bytes);
      }).toList();
    });
  }

  Future<void> _send() async {
    _sendButtonController.forward().then((_) => _sendButtonController.reverse());
    final text = _controller.text;
    final att = _pendingAttachments;
    _controller.clear();
    _pendingAttachments = [];
    _attachmentController.reverse();
    setState(() {});
    await ref.read(chatControllerProvider.notifier)
        .sendUserMessage(text, attachments: att);
    await Future.delayed(const Duration(milliseconds: 150)); // Reduced from 200ms to 150ms for faster response
    if (_scrollCtrl.hasClients && _stickToBottom) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 200), // Reduced from 250ms to 200ms for faster scroll
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rabbit Rive animation with error handling
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: RiveAnimation.asset(
                'assets/animations/rabbit.riv',
                fit: BoxFit.cover,
                onInit: (artboard) {
                  // Animation initialized successfully
                },
                placeHolder: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.pets,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start a new conversation',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Hello! I\'m your AI assistant. How can I help you today?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Quick start suggestions
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('💡 Ask me anything'),
              _buildSuggestionChip('📝 Help with writing'),
              _buildSuggestionChip('🧮 Solve problems'),
              _buildSuggestionChip('💬 Let\'s chat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _controller.text = text.replaceAll(RegExp(r'[💡📝🧮💬]\s'), '');
        _send();
      },
      backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Auto-scroll on new messages only if user is at bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stickToBottom && _scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
        );
      }
    });
    final chat = ref.watch(chatControllerProvider);
    final threadState = ref.watch(threadControllerProvider);
    
    // Check if thread changed to trigger message animations
    if (_previousThreadId != threadState.activeThreadId) {
      _previousThreadId = threadState.activeThreadId;
      _messageAnimationController.reset();
      _messageAnimationController.forward();
    }

    return Scaffold(
      drawer: const _ThreadDrawer(),
      appBar: AppBar(
        title: Consumer(builder: (context, ref, _) {
          final state = ref.watch(threadControllerProvider);
          String title = 'LM Studio Chat';
          if (state.threads.isNotEmpty) {
            final i = state.threads.indexWhere((t) => t.id == state.activeThreadId);
            final active = i >= 0 ? state.threads[i] : state.threads.first;
            title = active.title;
          }
          return Text(title);
        }),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Clear history',
            onPressed: () => ref.read(chatControllerProvider.notifier).clear(),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chat.messages.isEmpty 
              ? _buildEmptyState() // Show rabbit animation when no messages
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final m = chat.messages[index];
                final isUser = m.role == ChatRole.user;
                
                return AnimatedBuilder(
                  animation: _messageAnimationController,
                  builder: (context, child) {
                    // Calculate staggered animation delay for each message (faster stagger)
                    final delay = index * 0.08; // Reduced from 0.1 to 0.08 for faster sequence
                    final progress = (_messageAnimationController.value - delay).clamp(0.0, 1.0);
                    final rawAnimationValue = Curves.easeOutBack.transform(progress);
                    final animationValue = rawAnimationValue.clamp(0.0, 1.0);
                    
                    // Different slide directions for user vs AI messages (reduced distance)
                    final slideOffset = isUser 
                        ? Offset(30 * (1 - animationValue), 0)  // Reduced from 50 to 30
                        : Offset(-30 * (1 - animationValue), 0); // Reduced from 50 to 30
                    
                    return Transform.translate(
                      offset: slideOffset,
                      child: Opacity(
                        opacity: animationValue,
                        child: child,
                      ),
                    );
                  },
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Card(
                          color: isUser
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.content.isEmpty ? '(empty)' : m.content,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                if (m.attachments.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: m.attachments
                                        .map((a) => _AttachmentChip(att: a))
                                        .toList(),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('HH:mm').format(m.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (chat.error != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200), // Reduced from 300ms to 200ms for faster error display
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(chat.error!, style: const TextStyle(color: Colors.red)),
              ),
            ),
          if (_pendingAttachments.isNotEmpty)
            Container(
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._pendingAttachments.map((a) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InputChip(
                          label: Text(_basenamePath(a.path)),
                          onDeleted: () {
                            setState(() => _pendingAttachments.remove(a));
                          },
                        ),
                      )),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.attach_file),
                  ),
                  Expanded(
                    child: RawKeyboardListener(
                      focusNode: _inputFocusNode,
                      onKey: (RawKeyEvent e) {
                        if (e is RawKeyDownEvent && e.logicalKey == LogicalKeyboardKey.enter) {
                          final shift = HardwareKeyboard.instance.isShiftPressed;
                          if (!shift) {
                            // Prevent default newline by unfocusing and refocusing
                            if (_controller.text.trim().isNotEmpty && !ref.read(chatControllerProvider).isSending) {
                              _send();
                              // Remove focus to prevent TextField from adding a newline
                              _inputFocusNode.unfocus();
                              Future.delayed(const Duration(milliseconds: 10), () {
                                if (mounted) _inputFocusNode.requestFocus();
                              });
                            }
                          }
                        }
                      },
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        onChanged: (value) {
                          setState(() {}); // Update UI for send button state
                        },
                        decoration: const InputDecoration(
                          hintText: 'Message… (Enter to send, Shift+Enter for new line)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ScaleTransition(
                    scale: _sendButtonScale,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150), // Reduced from 200ms to 150ms for faster button color change
                      decoration: BoxDecoration(
                        color: ref.watch(chatControllerProvider).isSending 
                          ? Colors.grey 
                          : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: (ref.watch(chatControllerProvider).isSending || _controller.text.trim().isEmpty) 
                          ? null 
                          : _send,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150), // Reduced from 200ms to 150ms for faster icon switch
                          child: ref.watch(chatControllerProvider).isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final Attachment att;
  const _AttachmentChip({required this.att});

  @override
  Widget build(BuildContext context) {
  final name = _basenamePath(att.path);
    return InputChip(
      avatar: Icon(_iconForMime(att.mimeType)),
      label: Text(name, overflow: TextOverflow.ellipsis),
      onPressed: () {},
    );
  }

  IconData _iconForMime(String? mt) {
    if (mt == null) return Icons.insert_drive_file_outlined;
    if (mt.startsWith('image/')) return Icons.image_outlined;
    if (mt.startsWith('video/')) return Icons.videocam_outlined;
    if (mt == 'application/pdf') return Icons.picture_as_pdf_outlined;
    return Icons.insert_drive_file_outlined;
  }

  
}

class _ThreadDrawer extends ConsumerStatefulWidget {
  const _ThreadDrawer();

  @override
  ConsumerState<_ThreadDrawer> createState() => _ThreadDrawerState();
}

class _ThreadDrawerState extends ConsumerState<_ThreadDrawer> with TickerProviderStateMixin {
  late AnimationController _drawerController;
  late AnimationController _listController;
  late Animation<double> _fadeAnimation;
  final List<AnimationController> _itemControllers = [];

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      duration: const Duration(milliseconds: 600), // Increased from 400ms to 600ms
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 1200), // Increased from 800ms to 1200ms
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeOut,
    );
    _drawerController.forward();
    
    // Start list animation after drawer opens
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _listController.forward();
    });
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _listController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeItemControllers(int itemCount) {
    // Dispose existing controllers
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    _itemControllers.clear();
    
    // Create new controllers for each item
    for (int i = 0; i < itemCount; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 500), // Increased from 300ms to 500ms
        vsync: this,
      );
      _itemControllers.add(controller);

      // Stagger the animations - each item starts 300ms after the previous (even slower)
      Future.delayed(Duration(milliseconds: i * 300), () { // Increased from 200ms to 300ms
        if (mounted && controller.isCompleted == false) {
          controller.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final threads = ref.watch(threadControllerProvider).threads;
    final activeId = ref.watch(threadControllerProvider).activeThreadId;
    
    // Initialize item controllers when threads change
    if (_itemControllers.length != threads.length) {
      _initializeItemControllers(threads.length);
    }
    
    return Drawer(
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: const Text('New chat'),
                  leading: const Icon(Icons.add),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  onTap: () async {
                    await ref.read(threadControllerProvider.notifier).newThread();
                    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                  },
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: threads.length,
                  itemBuilder: (context, index) {
                    final t = threads[index];
                    final selected = t.id == activeId;
                    
                    // Use individual animation controller for each item
                    final animationController = index < _itemControllers.length 
                        ? _itemControllers[index] 
                        : null;
                    
                    if (animationController == null) {
                      return const SizedBox.shrink();
                    }
                    
                    return AnimatedBuilder(
                      animation: animationController,
                      builder: (context, child) {
                        final rawSlideValue = Curves.easeOutBack.transform(animationController.value);
                        final slideValue = rawSlideValue.clamp(0.0, 1.0);
                        final fadeValue = Curves.easeOut.transform(animationController.value).clamp(0.0, 1.0);
                        
                        return Transform.translate(
                          offset: Offset(-50 * (1 - slideValue), 0), // Reduced from -80 to -50
                          child: Opacity(
                            opacity: fadeValue,
                            child: child,
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: selected 
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        ),
                        child: ListTile(
                          selected: selected,
                          title: Text(t.title, overflow: TextOverflow.ellipsis),
                          onTap: () async {
                            // Trigger chat message animations when switching threads
                            ref.read(threadControllerProvider.notifier).setActive(t.id);
                            Navigator.of(context).pop();
                          },
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'rename') {
                                final controller = TextEditingController(text: t.title);
                                final title = await showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Rename chat'),
                                    content: TextField(controller: controller),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
                                    ],
                                  ),
                                );
                                if (title != null && title.isNotEmpty) {
                                  await ref.read(threadControllerProvider.notifier).rename(t.id, title);
                                }
                              } else if (v == 'delete') {
                                await ref.read(threadControllerProvider.notifier).delete(t.id);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'rename', child: Text('Rename')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
