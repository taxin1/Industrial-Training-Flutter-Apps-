# Quick Reference - Ghorer Bazar App

## App Overview
A bilingual (English/Bengali) e-commerce app for authentic Bangladeshi products with features like product browsing, search, categories, and shopping cart.

## Key Features
- 🛍️ Browse 12+ products across 14 categories
- 🔍 Real-time search (English & Bengali)
- 🏷️ Sale products with discount badges
- 📱 Responsive grid layout
- 🛒 Shopping cart with persistence
- 🌐 Bilingual support

## Tech Stack
- **Framework**: Flutter
- **State Management**: Riverpod
- **Backend**: Supabase (configured but using sample data)
- **Database**: Sembast (local)
- **Images**: cached_network_image
- **UI**: Material Design with custom theming

## Project Structure
```
lib/
├── config/
│   └── env_config.dart          # Environment variables
├── constants/
│   ├── app_colors.dart          # Color palette
│   └── app_strings.dart         # Text strings
├── models/
│   ├── product.dart             # Product model
│   ├── category.dart            # Category model
│   └── cart_item.dart           # Cart item model
├── providers/
│   ├── product_provider.dart    # Product state management
│   ├── category_provider.dart   # Category state management
│   ├── cart_provider.dart       # Cart state management
│   └── auth_provider.dart       # Authentication state
├── screens/
│   ├── home_screen.dart         # Main product listing
│   ├── product_detail_screen.dart
│   ├── category_screen.dart
│   ├── cart_screen.dart
│   ├── sign_in_screen.dart
│   └── sign_up_screen.dart
├── services/
│   ├── supabase_service.dart    # Supabase API
│   ├── auth_service.dart        # Authentication
│   └── sembast_service.dart     # Local database
├── widgets/
│   ├── product_card.dart        # Product card widget
│   ├── category_drawer.dart     # Navigation drawer
│   ├── custom_app_bar.dart      # App bar with search
│   └── price_display.dart       # Price formatting
└── main.dart                    # App entry point
```

## Running the App

### Prerequisites
```bash
flutter --version  # Should be 3.13.0 or higher
```

### Install Dependencies
```bash
cd "f:\Industrial Training (Flutter Apps)\flutter_application_5"
flutter pub get
```

### Run the App
```bash
# Run on connected device/emulator
flutter run

# Run on web
flutter run -d chrome

# Run on specific device
flutter devices
flutter run -d <device-id>
```

### Build for Production
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (on macOS)
flutter build ios --release

# Web
flutter build web --release
```

## Common Tasks

### Add New Product
Edit `lib/providers/product_provider.dart`:
```dart
Product(
  id: 'unique-id',
  name: 'Product Name',
  nameEn: 'English Name',
  nameBn: 'বাংলা নাম',
  description: 'Description',
  regularPrice: 1000.0,
  salePrice: 900.0,  // Optional
  images: ['https://...'],
  category: 'category-id',
  tags: ['tag1', 'tag2'],
  isOnSale: true,  // If on sale
),
```

### Add New Category
Edit `lib/providers/category_provider.dart`:
```dart
Category(
  id: 'category-id',
  name: 'Category Name',
  nameEn: 'English Name',
  nameBn: 'বাংলা নাম',
  icon: '🎯',  // Emoji icon
  color: '#FF5722',  // Hex color
  sortOrder: 15,
),
```

### Change App Colors
Edit `lib/constants/app_colors.dart`:
```dart
static const Color primary = Color(0xFF2E7D32);
static const Color primaryDark = Color(0xFF1B5E20);
static const Color accent = Color(0xFFFF8F00);
```

### Change App Text
Edit `lib/constants/app_strings.dart`:
```dart
static const String appName = 'Ghorer Bazar';
static const String appNameBn = 'ঘরের বাজার';
```

## Environment Variables

### Setup
```bash
# Copy example file
cp .env.example .env

# Edit with your credentials
nano .env
```

### Variables
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
```

## Debugging

### Enable Debug Logs
Check console for:
- `🟢 ProductsNotifier initialized` - Products loaded
- `🔍 Loading products` - Filtering in progress
- `✅ Loaded N filtered products` - Filter complete
- `🏠 HomeScreen initialized` - Screen ready

### Common Issues

**Products not showing?**
- Check `ProductsNotifier` logs
- Verify sample products in provider
- Check AsyncValue state

**Images not loading?**
- Verify internet connection
- Check image URLs
- Clear app cache

**Search not working?**
- Check console for filter logs
- Verify search query format
- Check product tags and names

**Categories not filtering?**
- Ensure category IDs match
- Check filter logic
- Verify category provider

## Testing

### Manual Testing Checklist
- [ ] Products display on home screen
- [ ] Search filters products correctly
- [ ] Categories work in drawer
- [ ] Product details open on tap
- [ ] Add to cart works
- [ ] Cart persists data
- [ ] Sale badges display correctly
- [ ] Prices format properly
- [ ] Bilingual text displays

### Code Quality
```bash
# Run analyzer
flutter analyze

# Run formatter
flutter format lib/

# Check for issues
flutter analyze --no-fatal-infos
```

## Performance Optimization

### Current Optimizations
- Immediate product loading (no API wait)
- Image caching with cached_network_image
- Efficient list filtering
- Debounced search
- Lazy loading grid

### Future Optimizations
- Pagination for large lists
- Image compression
- Code splitting
- Service worker for web
- Background data sync

## Deployment

### Android
1. Update version in `pubspec.yaml`
2. Build release: `flutter build appbundle`
3. Upload to Play Console

### iOS
1. Update version in `pubspec.yaml`
2. Build release: `flutter build ios --release`
3. Archive and upload via Xcode

### Web
1. Build: `flutter build web --release`
2. Deploy to hosting (Firebase, Netlify, etc.)

## Support & Resources

### Documentation
- Flutter: https://flutter.dev/docs
- Riverpod: https://riverpod.dev
- Supabase: https://supabase.io/docs

### Getting Help
- Check PRODUCT_RENDERING_FIX.md for detailed fixes
- Check ENV_SETUP.md for environment setup
- Review code comments for implementation details

## Quick Commands

```bash
# Hot reload
r

# Hot restart
R

# Open DevTools
d

# Quit
q

# Full restart
flutter run
```

## Version Info
- App Version: 1.0.0+1
- Flutter SDK: 3.13.0+
- Dart SDK: 3.1.0+

---
**Last Updated**: October 19, 2025
**Status**: ✅ Fully Functional
