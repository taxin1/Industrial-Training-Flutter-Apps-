import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_providers.dart';
import '../providers/favorites_provider.dart';
import 'news_detail_page.dart';

class StoriesListPage extends ConsumerStatefulWidget {
  final String type;
  const StoriesListPage({super.key, required this.type});

  @override
  ConsumerState<StoriesListPage> createState() => _StoriesListPageState();
}

class _StoriesListPageState extends ConsumerState<StoriesListPage> {
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
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(storiesProvider(widget.type));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(storiesProvider(widget.type));
      },
      child: storiesAsync.when(
        data: (ids) {
          if (ids.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No stories to display.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: ids.length > 50 ? 50 : ids.length, // Limit to 50 items for performance
            itemBuilder: (ctx, i) {
              final id = ids[i];
              return NewsItemTile(
                id: id,
                formatTime: formatUnixTime,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error: $e', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(storiesProvider(widget.type)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsItemTile extends ConsumerWidget {
  final int id;
  final String Function(int?) formatTime;

  const NewsItemTile({
    super.key,
    required this.id,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(newsDetailProvider(id));
    final favoritesNotifier = ref.read(favoritesProvider.notifier);
    final isFavorite = ref.watch(favoritesProvider).contains(id);

    return itemAsync.when(
      data: (data) {
        final title = data['title'] as String? ?? 'No title';
        final author = data['by'] as String? ?? 'Unknown';
        final score = data['score'] as int? ?? 0;
        final time = data['time'] as int?;
        final descendants = data['descendants'] as int? ?? 0;
        final url = data['url'] as String?;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
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
                    Text(formatTime(time), style: TextStyle(color: Colors.grey[600])),
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
                    if (url != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.link, size: 14, color: Colors.grey[600]),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'favorite',
                  child: Row(
                    children: [
                      Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                      const SizedBox(width: 8),
                      Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'favorite') {
                  favoritesNotifier.toggle(id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite 
                          ? 'Removed from favorites' 
                          : 'Added to favorites'
                      ),
                    ),
                  );
                }
              },
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
          title: Text('Error loading news item #$id'),
          subtitle: Text('$e'),
          leading: const Icon(Icons.error, color: Colors.red),
        ),
      ),
    );
  }
}
