import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Fetch story IDs
Future<List<int>> fetchStoryIds(String type) async {
  final url = 'https://hacker-news.firebaseio.com/v0/$type.json';
  final r = await http.get(Uri.parse(url));
  final decoded = json.decode(r.body);
  return (decoded as List<dynamic>).cast<int>();
}

// Fetch news story detail
Future<Map<String, dynamic>> fetchItem(int id) async {
  final r = await http.get(Uri.parse(
      'https://hacker-news.firebaseio.com/v0/item/$id.json'));
  return json.decode(r.body);
}

// Stories provider
final storiesProvider = FutureProvider.family<List<int>, String>((ref, type) async {
  final ids = await fetchStoryIds(type);
  return ids;
});

// News detail provider
final newsDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, id) {
  return fetchItem(id);
});
