import 'package:shared_preferences/shared_preferences.dart';

class DeletedNewsDB {
  static Future<List<int>> getDeleted() async {
    final prefs = await SharedPreferences.getInstance();
    final deleted = prefs.getStringList('deleted_news') ?? [];
    return deleted.map((e) => int.parse(e)).toList();
  }

  static Future<void> addDeleted(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final deleted = await getDeleted();
    if (!deleted.contains(id)) {
      await prefs.setStringList('deleted_news', [...deleted, id].map((e) => e.toString()).toList());
    }
  }
}
