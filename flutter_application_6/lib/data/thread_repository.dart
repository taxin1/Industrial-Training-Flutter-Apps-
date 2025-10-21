import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'package:sembast/sembast.dart';

import '../models/chat_thread.dart';
import 'chat_repository.dart';
import 'sembast_factory.dart';

class ThreadRepository {
  static const _dbName = 'chat_history.db';
  static const _storeName = 'threads';
  final _store = stringMapStoreFactory.store(_storeName);
  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    String dbPath;
    try {
      final dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      dbPath = p.join(dir.path, _dbName);
    } catch (_) {
      dbPath = _dbName; // web IndexedDB name
    }
    _db = await databaseFactoryDefault.openDatabase(dbPath);
    return _db!;
  }

  Future<void> dispose() async {
    await _db?.close();
    _db = null;
  }

  Future<List<ChatThread>> list() async {
    final db = await _open();
    final snaps = await _store.find(db);
    snaps.sort((a, b) => (b.value['updatedAt'] as String).compareTo(a.value['updatedAt'] as String));
    return snaps.map((e) => ChatThread.fromMap(e.value)).toList();
  }

  Future<ChatThread> create({String? title}) async {
    final db = await _open();
    final now = DateTime.now();
    final thread = ChatThread(
      id: now.microsecondsSinceEpoch.toString(),
      title: title ?? 'New chat',
      createdAt: now,
      updatedAt: now,
    );
    await _store.record(thread.id).put(db, thread.toMap());
    return thread;
  }

  Future<void> rename(String id, String title) async {
    final db = await _open();
    final rec = await _store.record(id).get(db) as Map<String, dynamic>?;
    if (rec == null) return;
    // Create a new map instead of modifying the immutable one
    final updatedRec = Map<String, dynamic>.from(rec);
    updatedRec['title'] = title;
    updatedRec['updatedAt'] = DateTime.now().toIso8601String();
    await _store.record(id).put(db, updatedRec);
  }

  Future<void> touch(String id) async {
    final db = await _open();
    final rec = await _store.record(id).get(db) as Map<String, dynamic>?;
    if (rec == null) return;
    // Create a new map instead of modifying the immutable one
    final updatedRec = Map<String, dynamic>.from(rec);
    updatedRec['updatedAt'] = DateTime.now().toIso8601String();
    await _store.record(id).put(db, updatedRec);
  }

  Future<void> deleteThread(String id, ChatRepository chatRepo) async {
    final db = await _open();
    await _store.record(id).delete(db);
    // cascade delete messages
    await chatRepo.deleteByThread(id);
  }
}
