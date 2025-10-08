import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_providers.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html_parser;

class NewsDetailPage extends ConsumerWidget {
  final int id;
  const NewsDetailPage({super.key, required this.id});

  String formatUnixTime(int? timestamp) {
    if (timestamp == null) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  String _cleanHtmlContent(String? htmlContent) {
    if (htmlContent == null || htmlContent.isEmpty) return '';
    
    try {
      // Parse HTML and extract text content
      final document = html_parser.parse(htmlContent);
      
      // Get text content and clean it up
      String text = document.body?.text ?? '';
      
      // Replace common HTML entities
      text = text.replaceAll('&quot;', '"');
      text = text.replaceAll('&amp;', '&');
      text = text.replaceAll('&lt;', '<');
      text = text.replaceAll('&gt;', '>');
      text = text.replaceAll('&nbsp;', ' ');
      text = text.replaceAll('&#x27;', "'");
      text = text.replaceAll('&#x2F;', '/');
      
      // Clean up extra whitespace
      text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      return text;
    } catch (e) {
      // If parsing fails, return the original content with basic cleanup
      return htmlContent
          .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
          .replaceAll('&quot;', '"')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&nbsp;', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }
  }

  List<String> _extractUrls(String? htmlContent) {
    if (htmlContent == null || htmlContent.isEmpty) return [];
    
    try {
      final document = html_parser.parse(htmlContent);
      final links = document.querySelectorAll('a[href]');
      
      return links
          .map((link) => link.attributes['href'] ?? '')
          .where((href) => href.isNotEmpty && (href.startsWith('http://') || href.startsWith('https://')))
          .toSet()
          .toList();
    } catch (e) {
      return [];
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String type) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar(context, '$type copied to clipboard');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(newsDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text('News #$id'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(newsDetailProvider(id));
            },
          ),
        ],
      ),
      body: detailAsync.when(
        data: (data) {
          final url = data['url'] as String?;
          final title = data['title'] as String? ?? 'No Title';
          final author = data['by'] as String? ?? 'Unknown';
          final score = data['score'] as int? ?? 0;
          final descendants = data['descendants'] as int? ?? 0;
          final int? time = data['time'] as int?;
          final formattedDate = formatUnixTime(time);
          final rawText = data['text'] as String? ?? '';
          final cleanText = _cleanHtmlContent(rawText);
          final extractedUrls = _extractUrls(rawText);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with news info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.person,
                            label: 'By $author',
                            onTap: () => _copyToClipboard(context, author, 'Author'),
                          ),
                          _InfoChip(
                            icon: Icons.access_time,
                            label: formattedDate,
                            onTap: () => _copyToClipboard(context, formattedDate, 'Date'),
                          ),
                          _InfoChip(
                            icon: Icons.thumb_up_outlined,
                            label: '$score points',
                            onTap: () => _copyToClipboard(context, score.toString(), 'Score'),
                          ),
                          _InfoChip(
                            icon: Icons.comment_outlined,
                            label: '$descendants comments',
                            onTap: () => _copyToClipboard(context, descendants.toString(), 'Comments count'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // URL section
                if (url != null && url.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Source URL:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _copyToClipboard(context, url, 'URL'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.link, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    url,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.copy, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Content section
                if (cleanText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Content:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Text(
                            cleanText,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Referenced URLs section
                if (extractedUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Referenced Links:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...extractedUrls.take(5).map((linkUrl) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => _copyToClipboard(context, linkUrl, 'Link'),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.05),
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.link, color: Colors.blue, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      linkUrl,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.copy, size: 14, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        )).toList(),
                        if (extractedUrls.length > 5)
                          Text(
                            '... and ${extractedUrls.length - 5} more links',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                      ],
                    ),
                  ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Actions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _copyToClipboard(
                              context,
                              'https://news.ycombinator.com/item?id=$id',
                              'Hacker News link',
                            ),
                            icon: const Icon(Icons.share),
                            label: const Text('Share HN Link'),
                          ),
                          if (url != null && url.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: () => _copyToClipboard(context, url, 'Source URL'),
                              icon: const Icon(Icons.link),
                              label: const Text('Copy URL'),
                            ),
                          OutlinedButton.icon(
                            onPressed: () => _copyToClipboard(context, title, 'Title'),
                            icon: const Icon(Icons.title),
                            label: const Text('Copy Title'),
                          ),
                          if (cleanText.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () => _copyToClipboard(context, cleanText, 'Content'),
                              icon: const Icon(Icons.content_copy),
                              label: const Text('Copy Content'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading news details',
                  style: TextStyle(fontSize: 18, color: Colors.red[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  '$e',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(newsDetailProvider(id)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
