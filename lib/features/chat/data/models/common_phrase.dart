class CommonPhrase {
  final int id;
  final String text;
  final String userId;

  CommonPhrase({
    required this.id,
    required this.text,
    required this.userId,
  });

  factory CommonPhrase.fromJson(Map<String, dynamic> json) {
    return CommonPhrase(
      id: json['id'] as int,
      text: json['text'] as String,
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'userId': userId,
    };
  }
}