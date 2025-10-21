import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/sembast_service.dart';

// Sembast service provider
final sembastServiceProvider = Provider<SembastService>((ref) {
  return SembastService();
});

// Cart state notifier
class CartNotifier extends StateNotifier<AsyncValue<List<CartItem>>> {
  CartNotifier(this._sembastService) : super(const AsyncValue.loading()) {
    loadCart();
  }
  
  final SembastService _sembastService;
  
  Future<void> loadCart() async {
    try {
      state = const AsyncValue.loading();
      final items = await _sembastService.getCartItems();
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      final currentItems = state.value ?? [];
      
      // Check if product already exists in cart
      final existingIndex = currentItems.indexWhere((item) => item.product.id == product.id);
      
      if (existingIndex >= 0) {
        // Update quantity
        final existingItem = currentItems[existingIndex];
        final newQuantity = existingItem.quantity + quantity;
        await updateQuantity(product.id, newQuantity);
      } else {
        // Add new item
        final cartItem = CartItem(
          id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
          product: product,
          quantity: quantity,
          addedAt: DateTime.now(),
        );
        
        await _sembastService.addToCart(cartItem);
        
        // Update state
        final updatedItems = [...currentItems, cartItem];
        state = AsyncValue.data(updatedItems);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      final currentItems = state.value ?? [];
      final itemIndex = currentItems.indexWhere((item) => item.product.id == productId);
      
      if (itemIndex >= 0) {
        final item = currentItems[itemIndex];
        
        if (quantity <= 0) {
          await removeFromCart(productId);
        } else {
          final updatedItem = item.copyWith(quantity: quantity);
          await _sembastService.updateCartItem(item.id, quantity);
          
          final updatedItems = [...currentItems];
          updatedItems[itemIndex] = updatedItem;
          state = AsyncValue.data(updatedItems);
        }
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> removeFromCart(String productId) async {
    try {
      final currentItems = state.value ?? [];
      final itemToRemove = currentItems.firstWhere((item) => item.product.id == productId);
      
      await _sembastService.removeFromCart(itemToRemove.id);
      
      final updatedItems = currentItems.where((item) => item.product.id != productId).toList();
      state = AsyncValue.data(updatedItems);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> clearCart() async {
    try {
      await _sembastService.clearCart();
      state = const AsyncValue.data([]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  bool isInCart(String productId) {
    final items = state.value ?? [];
    return items.any((item) => item.product.id == productId);
  }
  
  int getProductQuantity(String productId) {
    final items = state.value ?? [];
    final item = items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        id: '',
        product: Product(
          id: '',
          name: '',
          nameEn: '',
          nameBn: '',
          description: '',
          regularPrice: 0,
          images: [],
          category: '',
          tags: [],
          isOnSale: false,
        ),
        quantity: 0,
        addedAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }
}

// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<List<CartItem>>>((ref) {
  final sembastService = ref.watch(sembastServiceProvider);
  return CartNotifier(sembastService);
});

// Cart item count provider
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.when(
    data: (items) => items.fold(0, (sum, item) => sum + item.quantity),
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Cart total provider
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.when(
    data: (items) => items.fold(0.0, (sum, item) => sum + item.totalPrice),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Favorites notifier
class FavoritesNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  FavoritesNotifier(this._sembastService) : super(const AsyncValue.loading()) {
    loadFavorites();
  }
  
  final SembastService _sembastService;
  
  Future<void> loadFavorites() async {
    try {
      state = const AsyncValue.loading();
      final favorites = await _sembastService.getFavoriteProducts();
      state = AsyncValue.data(favorites);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> toggleFavorite(Product product) async {
    try {
      await _sembastService.toggleFavorite(product);
      await loadFavorites();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  bool isFavorite(String productId) {
    final favorites = state.value ?? [];
    return favorites.any((product) => product.id == productId);
  }
}

// Favorites provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<Product>>>((ref) {
  final sembastService = ref.watch(sembastServiceProvider);
  return FavoritesNotifier(sembastService);
});
