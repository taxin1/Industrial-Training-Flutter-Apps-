import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

class LmStudioClient {
  final String baseUrl; // e.g. http://localhost:1234/v1
  final String model; // e.g. qwen 0.6b (use exact loaded name)
  final String? apiKey; // LM Studio often doesn't require

  const LmStudioClient({
    required this.baseUrl,
    required this.model,
    this.apiKey,
  });

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        if (apiKey != null && apiKey!.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      };

  // Convert our ChatMessage list into OpenAI-style messages
  List<Map<String, dynamic>> _toOpenAIMessages(List<ChatMessage> history) {
    return history
        .map((m) => {
              'role': m.role.name,
              'content': m.content,
            })
        .toList();
  }

  Future<ChatMessage> chatCompletion({
    required List<ChatMessage> history,
    double temperature = 0.7,
    int maxTokens = 512,
  }) async {
    final uri = Uri.parse('$baseUrl/chat/completions');

    final body = jsonEncode({
      'model': model,
      'messages': _toOpenAIMessages(history),
      'temperature': temperature,
      'max_tokens': maxTokens,
      'stream': false,
    });

    final resp = await http.post(uri, headers: _headers(), body: body);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('LM Studio error ${resp.statusCode}: ${resp.body}');
    }
    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = map['choices'] as List<dynamic>?;
    final content = choices != null && choices.isNotEmpty
        ? (choices.first['message']?['content'] as String? ?? '')
        : '';

    return ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: ChatRole.assistant,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  // Streaming chat completion via SSE (OpenAI-compatible stream=true)
  Stream<String> chatCompletionStream({
    required List<ChatMessage> history,
    double temperature = 0.7,
    int maxTokens = 512,
  }) async* {
    final uri = Uri.parse('$baseUrl/chat/completions');
    final req = http.Request('POST', uri);
    req.headers.addAll(_headers());
    req.headers['Accept'] = 'text/event-stream';
    req.body = jsonEncode({
      'model': model,
      'messages': _toOpenAIMessages(history),
      'temperature': temperature,
      'max_tokens': maxTokens,
      'stream': true,
    });

    final resp = await req.send();
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final text = await resp.stream.bytesToString();
      throw Exception('LM Studio stream error ${resp.statusCode}: $text');
    }

    // Parse SSE: lines with "data: {...}" and ending with [DONE]
    await for (final chunk in resp.stream.transform(utf8.decoder)) {
      for (final line in const LineSplitter().convert(chunk)) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        if (trimmed.startsWith('data:')) {
          final data = trimmed.substring(5).trim();
          if (data == '[DONE]') return;
          try {
            final m = jsonDecode(data) as Map<String, dynamic>;
            final choices = m['choices'] as List<dynamic>?;
            if (choices != null && choices.isNotEmpty) {
              final delta = choices.first['delta'] as Map<String, dynamic>?;
              final token = delta?['content'] as String?;
              if (token != null && token.isNotEmpty) yield token;
            }
          } catch (_) {
            // ignore malformed chunks
          }
        }
      }
    }
  }
}
