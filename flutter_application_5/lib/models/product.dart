import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final String id;
  final String name;
  final String nameEn;
  final String nameBn;
  final String description;
  final double regularPrice;
  final double? salePrice;
  final List<String> images;
  final String category;
  final List<String> tags;
  final bool isOnSale;
  final bool inStock;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  Product({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameBn,
    required this.description,
    required this.regularPrice,
    this.salePrice,
    required this.images,
    required this.category,
    required this.tags,
    required this.isOnSale,
    this.inStock = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProductToJson(this);
  
  double get displayPrice => salePrice ?? regularPrice;
  
  bool get hasDiscount => salePrice != null && salePrice! < regularPrice;
  
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((regularPrice - salePrice!) / regularPrice * 100);
  }
  
  String get formattedRegularPrice => 'Tk ${regularPrice.toStringAsFixed(0)}';
  
  String get formattedSalePrice => salePrice != null 
      ? 'Tk ${salePrice!.toStringAsFixed(0)}'
      : formattedRegularPrice;
  
  String get primaryImage => images.isNotEmpty 
      ? images.first 
      : 'https://via.placeholder.com/300x300?text=No+Image';
}
