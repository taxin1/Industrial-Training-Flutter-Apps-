import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import 'services_provider.dart';

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getCategories();
});

// Active category provider
final activeCategoryProvider = StateProvider<Category?>((ref) => null);

// Category products count provider (optional)
final categoryProductCountProvider = FutureProvider.family<int, String>((ref, categoryId) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final products = await supabaseService.getProductsByCategory(categoryId);
  return products.length;
});

// Default categories for when Supabase is not configured
final defaultCategoriesProvider = Provider<List<Category>>((ref) {
  return [
    Category(
      id: 'offer-zone',
      name: 'OFFER ZONE',
      nameEn: 'OFFER ZONE',
      nameBn: 'অফার জোন',
      icon: '🏷️',
      color: '#FF5722',
      sortOrder: 1,
    ),
    Category(
      id: 'best-seller',
      name: 'Best Seller',
      nameEn: 'Best Seller',
      nameBn: 'বেস্ট সেলার',
      icon: '⭐',
      color: '#4CAF50',
      sortOrder: 2,
    ),
    Category(
      id: 'mustard-oil',
      name: 'Mustard Oil',
      nameEn: 'Mustard Oil',
      nameBn: 'সরিষার তেল',
      icon: '🫒',
      color: '#FF9800',
      sortOrder: 3,
    ),
    Category(
      id: 'ghee',
      name: 'Ghee (ঘি)',
      nameEn: 'Ghee',
      nameBn: 'ঘি',
      icon: '🧈',
      color: '#FFC107',
      sortOrder: 4,
    ),
    Category(
      id: 'dates',
      name: 'Dates (খেজুর)',
      nameEn: 'Dates',
      nameBn: 'খেজুর',
      icon: '🍯',
      color: '#795548',
      sortOrder: 5,
    ),
    Category(
      id: 'khejur-gud',
      name: 'খেজুর গুড়',
      nameEn: 'Date Palm Jaggery',
      nameBn: 'খেজুর গুড়',
      icon: '🍯',
      color: '#8D6E63',
      sortOrder: 6,
    ),
    Category(
      id: 'honey',
      name: 'Honey',
      nameEn: 'Honey',
      nameBn: 'মধু',
      icon: '🍯',
      color: '#FF8F00',
      sortOrder: 7,
    ),
    Category(
      id: 'masala',
      name: 'Masala',
      nameEn: 'Masala',
      nameBn: 'মসলা',
      icon: '🌶️',
      color: '#D32F2F',
      sortOrder: 8,
    ),
    Category(
      id: 'nuts-seeds',
      name: 'Nuts & Seeds',
      nameEn: 'Nuts & Seeds',
      nameBn: 'বাদাম ও বীজ',
      icon: '🥜',
      color: '#6D4C41',
      sortOrder: 9,
    ),
    Category(
      id: 'tea-coffee',
      name: 'Tea/Coffee',
      nameEn: 'Tea/Coffee',
      nameBn: 'চা/কফি',
      icon: '☕',
      color: '#5D4037',
      sortOrder: 10,
    ),
    Category(
      id: 'honeycomb',
      name: 'Honeycomb',
      nameEn: 'Honeycomb',
      nameBn: 'মৌচাক',
      icon: '🍯',
      color: '#FF6F00',
      sortOrder: 11,
    ),
    Category(
      id: 'organic-zone',
      name: 'Organic Zone',
      nameEn: 'Organic Zone',
      nameBn: 'অর্গানিক জোন',
      icon: '🌿',
      color: '#2E7D32',
      sortOrder: 12,
    ),
    Category(
      id: 'rice',
      name: 'Rice (চাল)',
      nameEn: 'Rice',
      nameBn: 'চাল',
      icon: '🍚',
      color: '#F4B400',
      sortOrder: 13,
    ),
    Category(
      id: 'spices',
      name: 'Spices (মসলা)',
      nameEn: 'Spices',
      nameBn: 'মসলা',
      icon: '🌶️',
      color: '#E91E63',
      sortOrder: 14,
    ),
  ];
});
