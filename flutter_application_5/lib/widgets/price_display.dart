import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/product.dart';

class PriceDisplay extends StatelessWidget {
  final Product product;
  final bool showLabels;
  final double fontSize;

  const PriceDisplay({
    super.key,
    required this.product,
    this.showLabels = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabels && product.hasDiscount) ...[
          // Sale Price with Label
          Row(
            children: [
              Text(
                AppStrings.salePrice,
                style: TextStyle(
                  fontSize: fontSize * 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                product.formattedSalePrice,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.salePrice,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Regular Price with Label and Strikethrough
          Row(
            children: [
              Text(
                AppStrings.regularPrice,
                style: TextStyle(
                  fontSize: fontSize * 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                product.formattedRegularPrice,
                style: TextStyle(
                  fontSize: fontSize * 0.9,
                  color: AppColors.regularPrice,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ] else if (showLabels && !product.hasDiscount) ...[
          // Regular Price with Label (No Sale)
          Row(
            children: [
              Text(
                AppStrings.regularPrice,
                style: TextStyle(
                  fontSize: fontSize * 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                product.formattedRegularPrice,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.salePrice,
                ),
              ),
            ],
          ),
        ] else ...[
          // Compact Display (No Labels)
          if (product.hasDiscount) ...[
            // Sale Price
            Text(
              product.formattedSalePrice,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.salePrice,
              ),
            ),
            // Regular Price with Strikethrough
            Text(
              product.formattedRegularPrice,
              style: TextStyle(
                fontSize: fontSize * 0.85,
                color: AppColors.regularPrice,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            // Discount Percentage
            if (product.discountPercentage > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.discount,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '-${product.discountPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ] else ...[
            // Regular Price Only
            Text(
              product.formattedRegularPrice,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.salePrice,
              ),
            ),
          ],
        ],
      ],
    );
  }
}
