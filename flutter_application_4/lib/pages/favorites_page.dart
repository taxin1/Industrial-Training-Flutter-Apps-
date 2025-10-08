import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorites_provider.dart';
import '../providers/news_providers.dart';
import 'news_detail_page.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final favoritesNotifier = ref.read(favoritesProvider.notifier);

    if (favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the heart icon on news items to add them to favorites',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final id = favorites.elementAt(index);
        return FavoriteNewsItem(
          id: id,
          onRemove: () {
            favoritesNotifier.toggle(id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Removed from favorites')),
            );
          },
        );
      },
    );
  }
}

class FavoriteNewsItem extends ConsumerWidget {
  final int id;
  final VoidCallback onRemove;

  const FavoriteNewsItem({
    super.key,
    required this.id,
    required this.onRemove,
  });

  String formatUnixTime(int? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(newsDetailProvider(id));

    return itemAsync.when(
      data: (data) {
        final title = data['title'] as String? ?? 'No title';
        final author = data['by'] as String? ?? 'Unknown';
        final score = data['score'] as int? ?? 0;
        final time = data['time'] as int?;
        final descendants = data['descendants'] as int? ?? 0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 24,
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(author, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(formatUnixTime(time), style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.thumb_up_outlined, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('$score', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 16),
                    Icon(Icons.comment_outlined, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('$descendants', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: onRemove,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NewsDetailPage(id: id)),
            ),
          ),
        );
      },
      loading: () => Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: const Icon(Icons.favorite, color: Colors.red),
          title: Container(
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (e, _) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: const Icon(Icons.error, color: Colors.red),
          title: Text('Error loading favorite #$id'),
          subtitle: Text('$e'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onRemove,
          ),
        ),
      ),
    );
  }
}