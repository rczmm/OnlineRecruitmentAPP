class Chat {
  final String id;
  final String name;
  final String lastMessage;
  final String avatarUrl;
  final DateTime lastMessageTime;

  Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    this.avatarUrl = '',
    required this.lastMessageTime,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'avatarUrl': avatarUrl,
      'lastMessageTime': lastMessageTime.toIso8601String(),
    };
  }
}