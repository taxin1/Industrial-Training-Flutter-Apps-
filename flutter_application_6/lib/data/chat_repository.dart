import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'package:sembast/sembast.dart';
import 'sembast_factory.dart';

import '../models/chat_message.dart';

class ChatRepository {
  static const _dbName = 'chat_history.db';
  static const _storeName = 'messages';

  final _store = stringMapStoreFactory.store(_storeName);
  Database? _db;

  Future<Database> _openDb() async {
    if (_db != null) return _db!;
    String dbPath;
    // On web, the factory uses IndexedDB and path is just a name; on IO, use a file path.
    if (identical(0, 0.0)) {
      // never executed, keeps both branches analyzable
    }
    try {
      // Try to build IO path; if it fails (web), we'll catch below and use name only.
      final dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      dbPath = p.join(dir.path, _dbName);
    } catch (_) {
      dbPath = _dbName;
    }
    _db = await databaseFactoryDefault.openDatabase(dbPath);
    return _db!;
  }

  Future<void> dispose() async {
    await _db?.close();
    _db = null;
  }

  Future<List<ChatMessage>> loadLast({int limit = 20, String? threadId}) async {
    final db = await _openDb();
    final records = await _store.find(
      db,
      finder: Finder(
        filter: threadId == null ? null : Filter.equals('threadId', threadId),
        sortOrders: [SortOrder('createdAt')],
      ),
    );
    final all = records
        .map((snap) => ChatMessage.fromMap(snap.value))
        .toList(growable: false);
    return all.length <= limit ? all : all.sublist(all.length - limit);
  }

  Future<void> addMessage(ChatMessage msg, {int limit = 20, String? threadId}) async {
    final db = await _openDb();
    final map = msg.toMap();
    if (threadId != null) map['threadId'] = threadId;
    await _store.record(msg.id).put(db, map);
    // enforce limit
  final existing = await _store.find(db, finder: Finder(filter: threadId == null ? null : Filter.equals('threadId', threadId)));
  final count = existing.length;
    if (count > limit) {
      final toDelete = await _store.find(
        db,
        finder: Finder(
          filter: threadId == null ? null : Filter.equals('threadId', threadId),
          sortOrders: [SortOrder('createdAt')],
          limit: count - limit,
        ),
      );
      for (final rec in toDelete) {
        await _store.record(rec.key).delete(db);
      }
    }
  }

  Future<void> clearAll() async {
    final db = await _openDb();
    await _store.delete(db);
  }

  Future<void> deleteByThread(String threadId) async {
    final db = await _openDb();
    final snaps = await _store.find(db, finder: Finder(filter: Filter.equals('threadId', threadId)));
    for (final s in snaps) {
      await _store.record(s.key).delete(db);
    }
  }
}
