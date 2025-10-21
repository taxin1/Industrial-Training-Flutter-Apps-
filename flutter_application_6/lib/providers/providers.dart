import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'package:sembast/sembast.dart';
import '../data/sembast_factory.dart';

import '../data/chat_repository.dart';
import '../data/thread_repository.dart';
import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import '../services/lm_studio_client.dart';

// Configuration providers
final lmBaseUrlProvider = StateProvider<String>((ref) => 'http://192.168.56.1:1234/v1');
final lmModelProvider = StateProvider<String>((ref) => 'qwen1.5-0.5b-chat');
final lmApiKeyProvider = StateProvider<String?>((ref) => null);

final lmClientProvider = Provider<LmStudioClient>((ref) {
  return LmStudioClient(
    baseUrl: ref.watch(lmBaseUrlProvider),
    model: ref.watch(lmModelProvider),
    apiKey: ref.watch(lmApiKeyProvider),
  );
});

final chatRepoProvider = Provider<ChatRepository>((ref) {
  final repo = ChatRepository();
  // Don't auto-dispose to prevent database closed errors
  return repo;
});

final threadRepoProvider = Provider<ThreadRepository>((ref) {
  final repo = ThreadRepository();
  // Don't auto-dispose to prevent database closed errors
  return repo;
});

final activeThreadIdProvider = StateProvider<String?>((ref) => null);

class ChatState {
  final List<ChatMessage> messages; // oldest -> newest
  final bool isSending;
  final String? error;
  const ChatState({this.messages = const [], this.isSending = false, this.error});

  ChatState copyWith({List<ChatMessage>? messages, bool? isSending, String? error}) =>
      ChatState(
        messages: messages ?? this.messages,
        isSending: isSending ?? this.isSending,
        error: error,
      );
}

class ChatController extends AutoDisposeNotifier<ChatState> {
  static const int memoryLimit = 20;

  late final ChatRepository _repo;
  late final LmStudioClient _client;
  String? _activeThreadId;

  @override
  ChatState build() {
    _repo = ref.read(chatRepoProvider);
    _client = ref.read(lmClientProvider);
    _load();
    return const ChatState();
  }

  void setActiveThread(String threadId) {
    if (_activeThreadId != threadId) {
      // Clear current state immediately when switching threads
      state = const ChatState(messages: []);
      _activeThreadId = threadId;
      _load(); // Load messages for the new thread
    }
  }

  Future<void> _load() async {
    if (_activeThreadId == null) return;
    final msgs = await _repo.loadLast(limit: memoryLimit, threadId: _activeThreadId);
    state = state.copyWith(messages: msgs);
  }

  Future<void> clear() async {
    if (_activeThreadId == null) return;
    await _repo.deleteByThread(_activeThreadId!);
    state = const ChatState(messages: []);
  }

  Future<void> sendUserMessage(String text, {List<Attachment> attachments = const []}) async {
    if (text.trim().isEmpty && attachments.isEmpty) return;
    // Ensure an active thread exists (ChatGPT-like behavior: create a new chat
    // the moment the user sends their first prompt)
    if (_activeThreadId == null) {
      final t = await ref.read(threadRepoProvider).create();
      _activeThreadId = t.id;
      // Keep ThreadController and activeThreadIdProvider in sync
      ref.read(threadControllerProvider.notifier).setActive(t.id);
      ref.read(activeThreadIdProvider.notifier).state = t.id;
    }
    final userMsg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: text,
      createdAt: DateTime.now(),
      attachments: attachments,
    );
    final newList = [...state.messages, userMsg];
    state = state.copyWith(messages: newList, isSending: true, error: null);
  await _repo.addMessage(userMsg, limit: memoryLimit, threadId: _activeThreadId);

    try {
      // only pass last 20 messages as context
      final base = newList.length <= memoryLimit
          ? newList
          : newList.sublist(newList.length - memoryLimit);

      // include simple attachment summary in the most recent user message content
      final contextList = List<ChatMessage>.from(base);
      if (attachments.isNotEmpty) {
        final last = contextList.last;
        if (last.role == ChatRole.user) {
          final names = attachments.map((a) => a.path.split('/').last).join(', ');
          contextList[contextList.length - 1] = last.copyWith(
            content: last.content.isEmpty
                ? 'Attachments: $names'
                : '${last.content}\n\nAttachments: $names',
          );
        }
      }

      // Stream tokens and update last assistant message incrementally
      var assistant = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: ChatRole.assistant,
        content: '',
        createdAt: DateTime.now(),
      );
      var liveList = [...newList, assistant];
      state = state.copyWith(messages: liveList, isSending: true);

      final stream = _client.chatCompletionStream(history: contextList);
      await for (final token in stream) {
        assistant = assistant.copyWith(content: assistant.content + token);
        liveList[liveList.length - 1] = assistant;
        state = state.copyWith(messages: List.of(liveList));
      }
      // done
      state = state.copyWith(isSending: false);
      await _repo.addMessage(assistant, limit: memoryLimit, threadId: _activeThreadId);

      // Auto-name thread on first response if title is default
      final threads = await ref.read(threadRepoProvider).list();
      ChatThread? active;
      if (threads.isNotEmpty) {
        final i = threads.indexWhere((t) => t.id == _activeThreadId);
        active = i >= 0 ? threads[i] : threads.first;
      }
      if (active != null && (active.title == 'New chat' || active.title.trim().isEmpty)) {
        final title = (text.isNotEmpty ? text : assistant.content).trim();
        final short = title.length > 50 ? '${title.substring(0, 50)}…' : title;
        await ref.read(threadRepoProvider).rename(active.id, short);
        await ref.read(threadRepoProvider).touch(active.id);
        await ref.read(threadControllerProvider.notifier)._load();
      } else if (active != null) {
        await ref.read(threadRepoProvider).touch(active.id);
      }
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }
}

final chatControllerProvider = AutoDisposeNotifierProvider<ChatController, ChatState>(
  ChatController.new,
);

class ThreadListState {
  final List<ChatThread> threads;
  final String? activeThreadId;
  const ThreadListState({this.threads = const [], this.activeThreadId});
}

class ThreadController extends AutoDisposeNotifier<ThreadListState> {
  late final ThreadRepository _repo;
  late final ChatRepository _chatRepo;

  @override
  ThreadListState build() {
    _repo = ref.read(threadRepoProvider);
    _chatRepo = ref.read(chatRepoProvider);
    _load();
    return const ThreadListState();
  }

  Future<void> _load() async {
    final all = await _repo.list();
    final current = ref.read(activeThreadIdProvider);

    // If no threads exist, create one immediately (ChatGPT-like default new chat)
    if (all.isEmpty) {
      final created = await _repo.create();
      state = ThreadListState(threads: [created], activeThreadId: created.id);
      ref.read(chatControllerProvider.notifier).setActiveThread(created.id);
      ref.read(activeThreadIdProvider.notifier).state = created.id;
      return;
    }

    // If current is null or no longer exists, pick the first available thread
    String? chosen = current;
    if (chosen == null || !all.any((t) => t.id == chosen)) {
      chosen = all.first.id;
    }
    state = ThreadListState(threads: all, activeThreadId: chosen);
    ref.read(chatControllerProvider.notifier).setActiveThread(chosen);
    ref.read(activeThreadIdProvider.notifier).state = chosen;
  }

  Future<void> newThread() async {
    final t = await _repo.create();
    await _load();
    setActive(t.id);
  }

  Future<void> rename(String id, String title) async {
    await _repo.rename(id, title);
    await _load();
  }

  Future<void> delete(String id) async {
    await _repo.deleteThread(id, _chatRepo);
    // After deletion, choose a new active thread (or create a fresh one) and update UI
    final all = await _repo.list();
    if (all.isEmpty) {
      final created = await _repo.create();
      state = ThreadListState(threads: [created], activeThreadId: created.id);
      ref.read(activeThreadIdProvider.notifier).state = created.id;
      ref.read(chatControllerProvider.notifier).setActiveThread(created.id);
    } else {
      final nextId = all.first.id;
      state = ThreadListState(threads: all, activeThreadId: nextId);
      ref.read(activeThreadIdProvider.notifier).state = nextId;
      ref.read(chatControllerProvider.notifier).setActiveThread(nextId);
    }
  }

  void setActive(String id) {
    state = ThreadListState(threads: state.threads, activeThreadId: id);
    ref.read(chatControllerProvider.notifier).setActiveThread(id);
    ref.read(activeThreadIdProvider.notifier).state = id;
  }
}

final threadControllerProvider = AutoDisposeNotifierProvider<ThreadController, ThreadListState>(
  ThreadController.new,
);

// -------------------- Settings --------------------
class SettingsState {
  final bool darkMode;
  final double fontScale; // 0.8 - 1.4 typically
  const SettingsState({this.darkMode = false, this.fontScale = 1.0});

  SettingsState copyWith({bool? darkMode, double? fontScale}) =>
      SettingsState(
        darkMode: darkMode ?? this.darkMode,
        fontScale: fontScale ?? this.fontScale,
      );
}

class SettingsRepository {
  // Very small persistence using Sembast in a separate store
  static const _storeName = 'settings';
  static const _key = 'global';

  Future<Map<String, dynamic>?> _readRaw(Ref ref) async {
  // openDb is private in ChatRepository, so we can't access directly; instead create our own minimal DB handle here.
    // To keep it simple and avoid additional deps, we'll use a tiny local store via Sembast again.
    // Implemented inline to avoid broad refactor.
    // We'll open our own DB path, same as chat repo location for convenience.
    // Re-using code requires duplication: create a minimal openDb here.
    return await _SettingsSembastHelper.read(_storeName, _key);
  }

  Future<void> _writeRaw(Ref ref, Map<String, dynamic> map) async {
    await _SettingsSembastHelper.write(_storeName, _key, map);
  }

  Future<SettingsState> load(Ref ref) async {
    final map = await _readRaw(ref);
    if (map == null) return const SettingsState();
    return SettingsState(
      darkMode: (map['darkMode'] as bool?) ?? false,
      fontScale: (map['fontScale'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Future<void> save(Ref ref, SettingsState state) async {
    await _writeRaw(ref, {
      'darkMode': state.darkMode,
      'fontScale': state.fontScale,
    });
  }
}

final settingsRepoProvider = Provider<SettingsRepository>((ref) => SettingsRepository());

class SettingsController extends Notifier<SettingsState> {
  late final SettingsRepository _repo;

  @override
  SettingsState build() {
    _repo = ref.read(settingsRepoProvider);
    // async load
    _load();
    return const SettingsState();
  }

  Future<void> _load() async {
    final s = await _repo.load(ref);
    state = s;
  }

  Future<void> setDarkMode(bool v) async {
    state = state.copyWith(darkMode: v);
    await _repo.save(ref, state);
  }

  Future<void> setFontScale(double v) async {
    state = state.copyWith(fontScale: v);
    await _repo.save(ref, state);
  }
}

final settingsControllerProvider = NotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);

// Minimal sembast helper for settings (same DB file as chat, separate store)
class _SettingsSembastHelper {
  static const _dbName = 'chat_history.db';
  static Future<Database> _db() async {
    String dbPath;
    try {
      final dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      dbPath = p.join(dir.path, _dbName);
    } catch (_) {
      // Web: IndexedDB uses just a name
      dbPath = _dbName;
    }
    return databaseFactoryDefault.openDatabase(dbPath);
  }

  static Future<Map<String, dynamic>?> read(String storeName, String key) async {
    final db = await _db();
    final store = stringMapStoreFactory.store(storeName);
    final rec = await store.record(key).get(db);
    // Do not close the DB here; let the main repo manage lifecycle
    return (rec as Map<String, dynamic>?);
  }

  static Future<void> write(String storeName, String key, Map<String, dynamic> map) async {
    final db = await _db();
    final store = stringMapStoreFactory.store(storeName);
    await store.record(key).put(db, map);
    // Do not close the DB here
  }
}
