import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../config/env_config.dart';

class SupabaseService {
  static late SupabaseClient _client;
  
  static SupabaseClient get client => _client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }
  
  // Products CRUD
  Future<List<Product>> getProducts({
    String? category,
    String? searchQuery,
    bool? onSale,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from('products').select('*');
      
      if (category != null) {
        query = query.eq('category', category);
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name_en.ilike.%$searchQuery%,name_bn.ilike.%$searchQuery%');
      }
      
      if (onSale == true) {
        query = query.neq('sale_price', '');
      }
      
      // Chain order, limit, and range directly before executing the query
      if (limit != null && offset != null) {
        final response = await query
            .order('created_at', ascending: false)
            .limit(limit)
            .range(offset, offset + limit - 1);
        return (response as List).map((data) => Product.fromJson(data)).toList();
      } else if (limit != null) {
        final response = await query
            .order('created_at', ascending: false)
            .limit(limit);
        return (response as List).map((data) => Product.fromJson(data)).toList();
      } else {
        final response = await query
            .order('created_at', ascending: false);
        return (response as List).map((data) => Product.fromJson(data)).toList();
      }
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
  
  Future<Product?> getProduct(String id) async {
    try {
      final response = await _client
          .from('products')
          .select('*')
          .eq('id', id)
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }
  
  Future<List<Product>> getFeaturedProducts() async {
    return getProducts(onSale: true, limit: 10);
  }
  
  Future<List<Product>> getProductsByCategory(String category) async {
    return getProducts(category: category);
  }
  
  // Categories CRUD
  Future<List<Category>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select('*')
          .eq('is_active', true)
          .order('sort_order');
      
      return (response as List).map((data) => Category.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
  
  // Search functionality
  Future<List<Product>> searchProducts(String query) async {
    return getProducts(searchQuery: query);
  }
  
  // Authentication (optional)
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }
  
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }
  
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  User? get currentUser => _client.auth.currentUser;
  
  // Create user profile (helper method)
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      print('SupabaseService: Creating profile for $userId');
      
      final result = await _client.from('user_profiles').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'address': address,
      }).select();
      
      print('SupabaseService: Profile created successfully: $result');
    } catch (e) {
      print('SupabaseService: Profile creation failed: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }
}
