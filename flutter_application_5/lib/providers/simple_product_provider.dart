import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

// Simple provider that returns a list of products directly
final productsProvider = Provider<List<Product>>((ref) {
  return [
    Product(
      id: '1',
      name: 'Fresh Organic Apples',
      nameEn: 'Fresh Organic Apples',
      nameBn: 'তাজা জৈব আপেল',
      description: 'Premium quality organic apples, fresh from the farm',
      regularPrice: 250.0,
      images: ['https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400'],
      category: 'fruits',
      tags: ['organic', 'fresh', 'fruits'],
      isOnSale: false,
    ),
    Product(
      id: '2',
      name: 'Premium Basmati Rice 5kg',
      nameEn: 'Premium Basmati Rice 5kg',
      nameBn: 'প্রিমিয়াম বাসমতী চাল ৫ কেজি',
      description: 'Long grain premium quality basmati rice',
      regularPrice: 850.0,
      salePrice: 750.0,
      images: ['https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400'],
      category: 'rice',
      tags: ['rice', 'basmati', 'grain'],
      isOnSale: true,
    ),
    Product(
      id: '3',
      name: 'Pure Sundarban Honey 1kg',
      nameEn: 'Pure Sundarban Honey 1kg',
      nameBn: 'খাঁটি সুন্দরবন মধু ১ কেজি',
      description: 'Raw natural honey from Sundarban forests',
      regularPrice: 1200.0,
      salePrice: 1000.0,
      images: ['https://images.unsplash.com/photo-1587049352846-4a222e784460?w=400'],
      category: 'honey',
      tags: ['honey', 'natural', 'sundarban'],
      isOnSale: true,
    ),
    Product(
      id: '4',
      name: 'Farm Fresh Eggs (12 pcs)',
      nameEn: 'Farm Fresh Eggs (12 pcs)',
      nameBn: 'ফার্ম ফ্রেশ ডিম (১২ টি)',
      description: 'Fresh organic eggs from free-range chickens',
      regularPrice: 180.0,
      images: ['https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400'],
      category: 'dairy-eggs',
      tags: ['eggs', 'organic', 'fresh'],
      isOnSale: false,
    ),
    Product(
      id: '5',
      name: 'Premium Ghee 500g',
      nameEn: 'Premium Ghee 500g',
      nameBn: 'প্রিমিয়াম ঘি ৫০০ গ্রাম',
      description: 'Pure cow ghee made from fresh milk',
      regularPrice: 900.0,
      salePrice: 850.0,
      images: ['https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=400'],
      category: 'ghee',
      tags: ['ghee', 'dairy', 'pure'],
      isOnSale: true,
    ),
    Product(
      id: '6',
      name: 'Organic Green Tea 100g',
      nameEn: 'Organic Green Tea 100g',
      nameBn: 'অর্গানিক গ্রিন টি ১০০ গ্রাম',
      description: 'Premium organic green tea leaves',
      regularPrice: 350.0,
      images: ['https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?w=400'],
      category: 'beverages',
      tags: ['tea', 'organic', 'green tea'],
      isOnSale: false,
    ),
    Product(
      id: '7',
      name: 'Fresh Tomatoes 1kg',
      nameEn: 'Fresh Tomatoes 1kg',
      nameBn: 'তাজা টমেটো ১ কেজি',
      description: 'Garden fresh ripe tomatoes',
      regularPrice: 60.0,
      images: ['https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400'],
      category: 'vegetables',
      tags: ['vegetables', 'fresh', 'tomatoes'],
      isOnSale: false,
    ),
    Product(
      id: '8',
      name: 'Premium Dates 500g',
      nameEn: 'Premium Dates 500g',
      nameBn: 'প্রিমিয়াম খেজুর ৫০০ গ্রাম',
      description: 'Sweet and nutritious premium quality dates',
      regularPrice: 450.0,
      salePrice: 400.0,
      images: ['https://images.unsplash.com/photo-1577069861033-55d04cec4ef5?w=400'],
      category: 'dates',
      tags: ['dates', 'dry fruits', 'sweet'],
      isOnSale: true,
    ),
    Product(
      id: '9',
      name: 'Fresh Milk 1 Liter',
      nameEn: 'Fresh Milk 1 Liter',
      nameBn: 'তাজা দুধ ১ লিটার',
      description: 'Pure fresh cow milk',
      regularPrice: 100.0,
      images: ['https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400'],
      category: 'dairy-eggs',
      tags: ['milk', 'dairy', 'fresh'],
      isOnSale: false,
    ),
    Product(
      id: '10',
      name: 'Mixed Nuts 250g',
      nameEn: 'Mixed Nuts 250g',
      nameBn: 'মিক্সড বাদাম ২৫০ গ্রাম',
      description: 'Healthy mix of almonds, cashews, and walnuts',
      regularPrice: 550.0,
      salePrice: 500.0,
      images: ['https://images.unsplash.com/photo-1508747703725-719777637510?w=400'],
      category: 'dry-fruits',
      tags: ['nuts', 'healthy', 'snacks'],
      isOnSale: true,
    ),
    Product(
      id: '11',
      name: 'Fresh Chicken 1kg',
      nameEn: 'Fresh Chicken 1kg',
      nameBn: 'তাজা মুরগি ১ কেজি',
      description: 'Fresh farm chicken, cleaned and ready to cook',
      regularPrice: 320.0,
      images: ['https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=400'],
      category: 'meat',
      tags: ['chicken', 'meat', 'fresh'],
      isOnSale: false,
    ),
    Product(
      id: '12',
      name: 'Premium Turmeric Powder 200g',
      nameEn: 'Premium Turmeric Powder 200g',
      nameBn: 'প্রিমিয়াম হলুদ গুঁড়া ২০০ গ্রাম',
      description: 'Pure turmeric powder with rich aroma',
      regularPrice: 150.0,
      salePrice: 130.0,
      images: ['https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=400'],
      category: 'spices',
      tags: ['spices', 'turmeric', 'powder'],
      isOnSale: true,
    ),
  ];
});

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered products based on search
final filteredProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  
  if (searchQuery.isEmpty) {
    return products;
  }
  
  final query = searchQuery.toLowerCase();
  return products.where((product) {
    return product.name.toLowerCase().contains(query) ||
           product.nameBn.contains(query) ||
           product.description.toLowerCase().contains(query) ||
           product.tags.any((tag) => tag.toLowerCase().contains(query));
  }).toList();
});
