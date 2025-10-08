import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Favorites provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<int>> {
  FavoritesNotifier() : super({}) {
    _init();
  }

  void _init() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorites') ?? [];
    state = favoriteIds.map((id) => int.parse(id)).toSet();
  }

  Future<void> toggle(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final newState = {...state};
    
    if (newState.contains(id)) {
      newState.remove(id);
    } else {
      newState.add(id);
    }
    
    state = newState;
    await prefs.setStringList(
      'favorites', 
      newState.map((id) => id.toString()).toList(),
    );
  }

  bool isFavorite(int id) => state.contains(id);
}

// Search provider
final searchProvider = StateProvider<String>((ref) => '');

// Filtered stories provider based on search
final filteredStoriesProvider = Provider.family<List<int>, List<int>>((ref, stories) {
  final search = ref.watch(searchProvider);
  if (search.isEmpty) return stories;
  
  // For now, we can't filter by title without fetching all items
  // In a real app, you might implement server-side search
  return stories;
});