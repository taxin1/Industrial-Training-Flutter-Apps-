import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class SembastService {
  static Database? _database;
  static final _cartStore = stringMapStoreFactory.store('cart');
  static final _favoritesStore = stringMapStoreFactory.store('favorites');
  static final _searchHistoryStore = stringMapStoreFactory.store('search_history');
  static final _settingsStore = stringMapStoreFactory.store('settings');
  
  // Initialize database
  static Future<void> initialize() async {
    if (_database != null) return;
    _database = await _initDatabase();
  }
  
  static Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  static Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, 'ghorer_bazar.db');
    return await databaseFactoryIo.openDatabase(dbPath);
  }
  
  // Cart Operations
  Future<List<CartItem>> getCartItems() async {
    final db = await _db;
    final records = await _cartStore.find(db);
    
    return records.map((record) {
      final data = record.value;
      return CartItem.fromJson(data);
    }).toList();
  }
  
  Future<void> addToCart(CartItem item) async {
    final db = await _db;
    await _cartStore.record(item.id).put(db, item.toJson());
  }
  
  Future<void> updateCartItem(String id, int quantity) async {
    final db = await _db;
    final record = await _cartStore.record(id).get(db);
    
    if (record != null) {
      final cartItem = CartItem.fromJson(record);
      final updatedItem = cartItem.copyWith(quantity: quantity);
      await _cartStore.record(id).put(db, updatedItem.toJson());
    }
  }
  
  Future<void> removeFromCart(String id) async {
    final db = await _db;
    await _cartStore.record(id).delete(db);
  }
  
  Future<void> clearCart() async {
    final db = await _db;
    await _cartStore.delete(db);
  }
  
  Future<int> getCartItemCount() async {
    final items = await getCartItems();
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }
  
  Future<double> getCartTotal() async {
    final items = await getCartItems();
    double total = 0.0;
    for (final item in items) {
      final price = await item.totalPrice;
      total += price;
    }
    return total;
  }
  
  // Favorites Operations
  Future<List<Product>> getFavoriteProducts() async {
    final db = await _db;
    final records = await _favoritesStore.find(db);
    
    return records.map((record) {
      final data = record.value;
      return Product.fromJson(data);
    }).toList();
  }
  
  Future<void> addToFavorites(Product product) async {
    final db = await _db;
    await _favoritesStore.record(product.id).put(db, product.toJson());
  }
  
  Future<void> removeFromFavorites(String productId) async {
    final db = await _db;
    await _favoritesStore.record(productId).delete(db);
  }
  
  Future<bool> isFavorite(String productId) async {
    final db = await _db;
    final record = await _favoritesStore.record(productId).get(db);
    return record != null;
  }
  
  Future<void> toggleFavorite(Product product) async {
    final isCurrentlyFavorite = await isFavorite(product.id);
    if (isCurrentlyFavorite) {
      await removeFromFavorites(product.id);
    } else {
      await addToFavorites(product);
    }
  }
  
  // Search History
  Future<List<String>> getSearchHistory() async {
    final db = await _db;
    final records = await _searchHistoryStore.find(db);
    
    return records.map((record) => record.value['query'] as String).toList();
  }
  
  Future<void> addToSearchHistory(String query) async {
    final db = await _db;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _searchHistoryStore.record(timestamp).put(db, {
      'query': query,
      'timestamp': timestamp,
    });
    
    // Keep only last 20 searches
    final records = await _searchHistoryStore.find(db);
    if (records.length > 20) {
      final oldestRecords = records.take(records.length - 20);
      for (final record in oldestRecords) {
        await record.ref.delete(db);
      }
    }
  }
  
  Future<void> clearSearchHistory() async {
    final db = await _db;
    await _searchHistoryStore.delete(db);
  }
  
  // Settings
  Future<Map<String, dynamic>> getSettings() async {
    final db = await _db;
    final record = await _settingsStore.record('app_settings').get(db);
    return record ?? {
      'theme_mode': 'light',
      'language': 'en',
      'notifications': true,
    };
  }
  
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    final db = await _db;
    await _settingsStore.record('app_settings').put(db, settings);
  }
  
  Future<T?> getSetting<T>(String key) async {
    final settings = await getSettings();
    return settings[key] as T?;
  }
  
  Future<void> setSetting(String key, dynamic value) async {
    final settings = await getSettings();
    settings[key] = value;
    await updateSettings(settings);
  }
}
