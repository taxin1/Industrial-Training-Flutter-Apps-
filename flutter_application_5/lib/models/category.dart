import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final String id;
  final String name;
  final String nameEn;
  final String nameBn;
  final String icon;
  final String color;
  final int sortOrder;
  final bool isActive;
  
  Category({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameBn,
    required this.icon,
    required this.color,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
