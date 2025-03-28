class Chat {
  final String id;
  final String name;
  final String lastMessage;
  final String avatarUrl;
  final DateTime lastMessageTime;
  final String senderId;
  final String recipientId;


  Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    this.avatarUrl = '',
    required this.lastMessageTime,
    required this.senderId,
    required this.recipientId,
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
      senderId: json['senderId'] ?? '',
      recipientId: json['recipientId'] ?? '',
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