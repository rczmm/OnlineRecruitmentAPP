import 'package:zhaopingapp/models/visit_trend_point.dart'; // Adjust path
import 'package:zhaopingapp/models/viewer_info.dart'; // Adjust path

class InteractionService {
  // Replace with actual API calls using Dio or http
  Future<List<VisitTrendPoint>> getVisitTrend() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    // Mock data - Replace with API call
    return List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      return VisitTrendPoint(date: date, count: (index * 2 % 5) + 1); // Example counts
    });
    // throw Exception("Failed to load trend data"); // Simulate error
  }

  Future<List<ViewerInfo>> getViewers() async {
    await Future.delayed(const Duration(milliseconds: 1200)); // Simulate network delay
    // Mock data - Replace with API call
    return [
      ViewerInfo(userId: '101', name: '张三 HR', company: '科技公司 A', viewedAt: DateTime.now().subtract(Duration(hours: 2)), avatarUrl: 'https://via.placeholder.com/150/92c952'),
      ViewerInfo(userId: '102', name: '李四招聘专员', company: '设计工作室 B', viewedAt: DateTime.now().subtract(Duration(days: 1))),
      ViewerInfo(userId: '103', name: '王五技术总监', company: '互联网大厂 C', viewedAt: DateTime.now().subtract(Duration(days: 3)), avatarUrl: 'https://via.placeholder.com/150/771796'),
    ];
    // throw Exception("Failed to load viewers"); // Simulate error
  }
}