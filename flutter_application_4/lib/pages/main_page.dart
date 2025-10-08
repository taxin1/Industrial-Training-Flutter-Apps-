import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stories_list_page.dart';
import 'favorites_page.dart';
import '../providers/news_providers.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});
  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int selectedIndex = 0;

  static const List<String> storyTypes = ['topstories', 'beststories', 'newstories'];
  List<String> get titles => ['Top Stories', 'Best Stories', 'New Stories', 'Favorites'];
  List<IconData> get icons => [Icons.trending_up, Icons.star, Icons.new_releases, Icons.favorite];

  void _refreshCurrentPage() {
    if (selectedIndex < storyTypes.length) {
      // Invalidate the current story provider to refresh data
      ref.invalidate(storiesProvider(storyTypes[selectedIndex]));
    }
    // Note: Favorites page handles its own refresh
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;
    
    switch (selectedIndex) {
      case 0:
        currentPage = const StoriesListPage(type: 'topstories');
        break;
      case 1:
        currentPage = const StoriesListPage(type: 'beststories');
        break;
      case 2:
        currentPage = const StoriesListPage(type: 'newstories');
        break;
      case 3:
        currentPage = const FavoritesPage();
        break;
      default:
        currentPage = const StoriesListPage(type: 'topstories');
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _refreshCurrentPage,
          child: Row(
            children: [
              Icon(
                Icons.article,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Hacker News',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        elevation: 2,
        shadowColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCurrentPage,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(icons[0]),
            label: 'Top',
          ),
          BottomNavigationBarItem(
            icon: Icon(icons[1]),
            label: 'Best',
          ),
          BottomNavigationBarItem(
            icon: Icon(icons[2]),
            label: 'New',
          ),
          BottomNavigationBarItem(
            icon: Icon(icons[3]),
            label: 'Favorites',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.article,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'Hacker News',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Reader App',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(titles.length, (index) {
            final isSelected = selectedIndex == index;
            return ListTile(
              leading: Icon(
                icons[index],
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
              title: Text(
                titles[index],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
              selected: isSelected,
              selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                Navigator.pop(context);
              },
            );
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showInfoDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text('About Hacker News Reader'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This app displays the latest stories from Hacker News using their official API.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Browse Top, Best, and New stories'),
              Text('• Add stories to favorites'),
              Text('• Read detailed news information'),
              Text('• Copy links and content'),
              Text('• Pull to refresh or tap logo/refresh button'),
              SizedBox(height: 12),
              Text(
                'Data provided by: news.ycombinator.com',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
