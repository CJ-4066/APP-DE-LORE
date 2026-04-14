class CommunityChatMessage {
  CommunityChatMessage({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String authorName;
  final String authorRole;
  final String body;
  final String createdAt;

  factory CommunityChatMessage.fromJson(Map<String, dynamic> json) {
    return CommunityChatMessage(
      id: json['id'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorRole: json['authorRole'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
