import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

// Sample Products (fallback data) - Enhanced with better variety
final sampleProductsProvider = Provider<List<Product>>((ref) {
  return [
    Product(
      id: '1',
      name: 'USDA Organic Beetroot Powder 250g',
      nameEn: 'USDA Organic Beetroot Powder 250g',
      nameBn: 'ইউএসডিএ অর্গানিক বিটরুট পাউডার ২৫০গ্রাম',
      description: 'Premium organic beetroot powder packed with nutrients and antioxidants. Perfect for smoothies and health drinks.',
      regularPrice: 1000.0,
      images: ['https://images.unsplash.com/photo-1590779033100-9f60a05a013d?w=400&h=400&fit=crop'],
      category: 'organic-zone',
      tags: ['organic', 'powder', 'beetroot', 'USDA'],
      isOnSale: false,
    ),
    Product(
      id: '2',
      name: 'সুন্দরবনের মধু/Sundarban Honey 1kg',
      nameEn: 'Sundarban Honey 1kg',
      nameBn: 'সুন্দরবনের মধু ১ কেজি',
      description: 'Pure raw honey collected from the Sundarban mangrove forests. Rich in natural enzymes and minerals.',
      regularPrice: 2500.0,
      salePrice: 2200.0,
      images: ['https://images.unsplash.com/photo-1587049352846-4a222e784460?w=400&h=400&fit=crop'],
      category: 'honey',
      tags: ['honey', 'sundarban', 'natural', 'raw'],
      isOnSale: true,
    ),
    Product(
      id: '3',
      name: 'Gawa Ghee/গাওয়া ঘি (১ কেজি)',
      nameEn: 'Gawa Ghee 1kg',
      nameBn: 'গাওয়া ঘি ১ কেজি',
      description: 'Pure cow ghee made from fresh milk. Traditional method of preparation ensures authentic taste and aroma.',
      regularPrice: 1800.0,
      salePrice: 1700.0,
      images: ['https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=400&h=400&fit=crop'],
      category: 'ghee',
      tags: ['ghee', 'cow', 'pure', 'traditional'],
      isOnSale: true,
    ),
    Product(
      id: '4',
      name: 'Ajwa Premium Dates 1kg',
      nameEn: 'Ajwa Premium Dates 1kg',
      nameBn: 'আজওয়া প্রিমিয়াম খেজুর ১ কেজি',
      description: 'Premium quality Ajwa dates from Madina. Known for their exceptional taste and nutritional benefits.',
      regularPrice: 2000.0,
      salePrice: 1800.0,
      images: ['https://images.unsplash.com/photo-1577003833154-a9e846b0408f?w=400&h=400&fit=crop'],
      category: 'dates',
      tags: ['dates', 'ajwa', 'premium', 'madina'],
      isOnSale: true,
    ),
    Product(
      id: '5',
      name: 'দেশি সরিষার তেল/Deshi Mustard Oil 5ltr',
      nameEn: 'Deshi Mustard Oil 5ltr',
      nameBn: 'দেশি সরিষার তেল ৫ লিটার',
      description: 'Pure mustard oil extracted from local mustard seeds. Perfect for cooking and traditional use.',
      regularPrice: 1550.0,
      images: ['https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&h=400&fit=crop'],
      category: 'mustard-oil',
      tags: ['oil', 'mustard', 'cooking', 'local'],
      isOnSale: false,
    ),
    Product(
      id: '6',
      name: 'Honey Special Combo Pack (4 types)',
      nameEn: 'Honey Special Combo Pack',
      nameBn: 'মধুর বিশেষ কম্বো প্যাক',
      description: 'A special combo pack containing 4 different types of premium honey varieties.',
      regularPrice: 1950.0,
      salePrice: 1650.0,
      images: ['https://images.unsplash.com/photo-1558642452-9d2a7deb7f62?w=400&h=400&fit=crop'],
      category: 'honey',
      tags: ['honey', 'combo', 'variety', 'special'],
      isOnSale: true,
    ),
    Product(
      id: '7',
      name: 'লিচু ফুলের মধু/Lichu Flower Honey 1kg',
      nameEn: 'Lichu Flower Honey 1kg',
      nameBn: 'লিচু ফুলের মধু ১ কেজি',
      description: 'Pure honey collected from litchi flowers. Sweet and aromatic with a distinct floral taste.',
      regularPrice: 1200.0,
      salePrice: 1000.0,
      images: ['https://images.unsplash.com/photo-1471943311424-646960669fbc?w=400&h=400&fit=crop'],
      category: 'honey',
      tags: ['honey', 'lichu', 'floral', 'aromatic'],
      isOnSale: true,
    ),
    Product(
      id: '8',
      name: 'Sukkari Mufattal Malaki Dates 3kg',
      nameEn: 'Sukkari Mufattal Malaki Dates 3kg',
      nameBn: 'সুক্করি মুফাত্তাল মালাকি খেজুর ৩ কেজি',
      description: 'Premium Sukkari dates with exceptional sweetness and soft texture. Perfect for iftar and special occasions.',
      regularPrice: 4500.0,
      salePrice: 4000.0,
      images: ['https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?w=400&h=400&fit=crop'],
      category: 'dates',
      tags: ['dates', 'sukkari', 'premium', 'soft'],
      isOnSale: true,
    ),
    Product(
      id: '9',
      name: 'Kalo Jeera/Black Cumin Seeds 500g',
      nameEn: 'Black Cumin Seeds 500g',
      nameBn: 'কালো জিরা ৫০০ গ্রাম',
      description: 'Premium quality black cumin seeds known for their medicinal properties and aromatic flavor.',
      regularPrice: 800.0,
      salePrice: 750.0,
      images: ['https://images.unsplash.com/photo-1596040033229-a0b3b5b19a9b?w=400&h=400&fit=crop'],
      category: 'spices',
      tags: ['spices', 'black-cumin', 'kalo-jeera', 'medicinal'],
      isOnSale: true,
    ),
    Product(
      id: '10',
      name: 'Organic Turmeric Powder/হলুদ গুঁড়া 500g',
      nameEn: 'Organic Turmeric Powder 500g',
      nameBn: 'অর্গানিক হলুদ গুঁড়া ৫০০ গ্রাম',
      description: 'Pure organic turmeric powder with high curcumin content. Ideal for cooking and health benefits.',
      regularPrice: 600.0,
      images: ['https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=400&h=400&fit=crop'],
      category: 'spices',
      tags: ['turmeric', 'organic', 'spices', 'health'],
      isOnSale: false,
    ),
    Product(
      id: '11',
      name: 'Basmati Rice/বাসমতি চাল 5kg',
      nameEn: 'Premium Basmati Rice 5kg',
      nameBn: 'প্রিমিয়াম বাসমতি চাল ৫ কেজি',
      description: 'Aged basmati rice with long grains and aromatic fragrance. Perfect for biriyani and special dishes.',
      regularPrice: 1200.0,
      salePrice: 1100.0,
      images: ['https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop'],
      category: 'rice',
      tags: ['rice', 'basmati', 'premium', 'aromatic'],
      isOnSale: true,
    ),
    Product(
      id: '12',
      name: 'Chinigura Rice/চিনিগুঁড়া চাল 2kg',
      nameEn: 'Chinigura Rice 2kg',
      nameBn: 'চিনিগুঁড়া চাল ২ কেজি',
      description: 'Special aromatic rice variety from Bangladesh. Perfect for polao and khichuri.',
      regularPrice: 900.0,
      images: ['https://images.unsplash.com/photo-1516684732162-798a0062be99?w=400&h=400&fit=crop'],
      category: 'rice',
      tags: ['rice', 'chinigura', 'aromatic', 'bangladeshi'],
      isOnSale: false,
    ),
  ];
});

// Products state notifier - Fixed to load sample products immediately
class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductsNotifier(this._sampleProducts) 
      : super(AsyncValue.data(_sampleProducts)) {
    // Products are loaded immediately in the constructor
    print('🟢 ProductsNotifier initialized with ${_sampleProducts.length} products');
  }
  
  final List<Product> _sampleProducts;
  
  Future<void> loadProducts({
    String? category,
    String? searchQuery,
    bool? onSale,
  }) async {
    try {
      print('🔍 Loading products - category: $category, search: $searchQuery, onSale: $onSale');
      // Always use sample data for now (until Supabase is properly configured)
      final filteredProducts = _getFilteredSampleProducts(category, searchQuery, onSale);
      print('✅ Loaded ${filteredProducts.length} filtered products');
      state = AsyncValue.data(filteredProducts);
    } catch (error) {
      print('❌ Error loading products: $error');
      // Fallback to all sample products on error
      state = AsyncValue.data(_sampleProducts);
    }
  }
  
  List<Product> _getFilteredSampleProducts(String? category, String? searchQuery, bool? onSale) {
    var products = List<Product>.from(_sampleProducts);
    
    // Filter by category
    if (category != null) {
      products = products.where((p) => p.category == category).toList();
    }
    
    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      products = products.where((p) => 
        p.name.toLowerCase().contains(query) ||
        p.nameEn.toLowerCase().contains(query) ||
        p.nameBn.toLowerCase().contains(query) ||
        p.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }
    
    // Filter by sale status
    if (onSale == true) {
      products = products.where((p) => p.hasDiscount).toList();
    }
    
    return products;
  }
  
  Future<void> searchProducts(String query) async {
    await loadProducts(searchQuery: query);
  }
  
  Future<void> loadProductsByCategory(String category) async {
    await loadProducts(category: category);
  }
  
  Future<void> loadSaleProducts() async {
    await loadProducts(onSale: true);
  }
  
  Future<void> refresh() async {
    await loadProducts();
  }
}

// Products provider
final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final sampleProducts = ref.watch(sampleProductsProvider);
  return ProductsNotifier(sampleProducts);
});

// Featured products provider - Simplified
final featuredProductsProvider = Provider<List<Product>>((ref) {
  final sampleProducts = ref.watch(sampleProductsProvider);
  return sampleProducts.where((p) => p.hasDiscount).toList();
});

// Product detail provider - Simplified
final productDetailProvider = FutureProvider.family<Product?, String>((ref, productId) async {
  final sampleProducts = ref.watch(sampleProductsProvider);
  try {
    return sampleProducts.firstWhere((p) => p.id == productId);
  } catch (e) {
    return sampleProducts.isNotEmpty ? sampleProducts.first : null;
  }
});

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected category state
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Product filters state
class ProductFilters {
  final double? minPrice;
  final double? maxPrice;
  final bool? onSale;
  final String? sortBy;
  
  const ProductFilters({
    this.minPrice,
    this.maxPrice,
    this.onSale,
    this.sortBy,
  });
  
  ProductFilters copyWith({
    double? minPrice,
    double? maxPrice,
    bool? onSale,
    String? sortBy,
  }) {
    return ProductFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      onSale: onSale ?? this.onSale,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class ProductFiltersNotifier extends StateNotifier<ProductFilters> {
  ProductFiltersNotifier() : super(const ProductFilters());
  
  void updateFilters({
    double? minPrice,
    double? maxPrice,
    bool? onSale,
    String? sortBy,
  }) {
    state = state.copyWith(
      minPrice: minPrice,
      maxPrice: maxPrice,
      onSale: onSale,
      sortBy: sortBy,
    );
  }
  
  void clearFilters() {
    state = const ProductFilters();
  }
}

final productFiltersProvider = StateNotifierProvider<ProductFiltersNotifier, ProductFilters>((ref) {
  return ProductFiltersNotifier();
});

// Filtered products provider
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final products = ref.watch(productsProvider);
  final filters = ref.watch(productFiltersProvider);
  
  return products.when(
    data: (productList) {
      var filtered = productList.where((product) {
        // Price filter
        if (filters.minPrice != null && product.displayPrice < filters.minPrice!) {
          return false;
        }
        if (filters.maxPrice != null && product.displayPrice > filters.maxPrice!) {
          return false;
        }
        
        // Sale filter
        if (filters.onSale == true && !product.hasDiscount) {
          return false;
        }
        
        return true;
      }).toList();
      
      // Sorting
      switch (filters.sortBy) {
        case 'price_asc':
          filtered.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
          break;
        case 'price_desc':
          filtered.sort((a, b) => b.displayPrice.compareTo(a.displayPrice));
          break;
        case 'name_asc':
          filtered.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'name_desc':
          filtered.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'newest':
        default:
          // Already sorted by newest from API
          break;
      }
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});
