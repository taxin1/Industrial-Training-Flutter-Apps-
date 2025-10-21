class ChatThread {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatThread({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatThread copyWith({String? title, DateTime? updatedAt}) => ChatThread(
        id: id,
        title: title ?? this.title,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ChatThread.fromMap(Map<String, dynamic> map) => ChatThread(
        id: map['id'] as String,
        title: map['title'] as String? ?? 'New chat',
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}
