class ViewerInfo {
  final String userId;
  final String name;
  final String company;
  final String? avatarUrl;
  final DateTime viewedAt;

  ViewerInfo({
    required this.userId,
    required this.name,
    required this.company,
    this.avatarUrl,
    required this.viewedAt,
  });
}
