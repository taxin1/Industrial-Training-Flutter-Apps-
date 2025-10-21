import 'dart:convert';
import 'dart:typed_data';

enum ChatRole { user, assistant, system }

class Attachment {
  final String path; // local file path
  final String? mimeType;
  final int? size;
  final Uint8List? bytes; // not persisted, used for web/quick reads

  Attachment({required this.path, this.mimeType, this.size, this.bytes});

  Map<String, dynamic> toMap() => {
        'path': path,
        'mimeType': mimeType,
        'size': size,
    // bytes intentionally omitted from persistence
      };

  factory Attachment.fromMap(Map<String, dynamic> map) => Attachment(
        path: map['path'] as String,
        mimeType: map['mimeType'] as String?,
        size: map['size'] as int?,
        bytes: null,
      );
}

class ChatMessage {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;
  final List<Attachment> attachments;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.attachments = const [],
  });

  ChatMessage copyWith({
    String? id,
    ChatRole? role,
    String? content,
    DateTime? createdAt,
    List<Attachment>? attachments,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        role: role ?? this.role,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        attachments: attachments ?? this.attachments,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'role': role.name,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'attachments': attachments.map((e) => e.toMap()).toList(),
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'] as String,
        role: ChatRole.values.firstWhere((r) => r.name == map['role']),
        content: map['content'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        attachments: (map['attachments'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .map(Attachment.fromMap)
            .toList(),
      );

  String toJson() => jsonEncode(toMap());
  factory ChatMessage.fromJson(String source) =>
      ChatMessage.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
