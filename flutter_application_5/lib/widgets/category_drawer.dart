import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/category_provider.dart';
import '../screens/category_screen.dart';

class CategoryDrawer extends ConsumerWidget {
  const CategoryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final defaultCategories = ref.watch(defaultCategoriesProvider);

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
            ),
            child: const SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        'GB',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppStrings.appTagline,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Categories List
          Expanded(
            child: categoriesAsync.when(
              data: (categories) => _buildCategoriesList(
                context,
                ref,
                categories.isNotEmpty ? categories : defaultCategories,
              ),
              loading: () => _buildCategoriesList(context, ref, defaultCategories),
              error: (_, __) => _buildCategoriesList(context, ref, defaultCategories),
            ),
          ),
          // Footer
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context, WidgetRef ref, List categories) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(int.parse(category.color.replaceFirst('#', '0xFF'))),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                category.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          title: Text(
            category.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textLight,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryScreen(category: category),
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 ${AppStrings.appName}. All rights reserved.',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'Your trusted online marketplace for authentic Bangladeshi products. '
            'From organic honey to traditional spices, we bring the best of '
            'Bangladesh to your doorstep.',
          ),
        ),
      ],
    );
  }
}
