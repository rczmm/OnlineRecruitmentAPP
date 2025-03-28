import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zhaopingapp/core/network/dio_client.dart';
import 'package:zhaopingapp/models/job.dart';

class JobService {
  Future<List<Job>> getRecommendedJobs({String? tag}) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final allJobs = [
      Job(
        id: 'j001',
        title: '数据分析师',
        salary: '15-25K',
        company: '金融科技 D',
        companySize: '500-1000人',
        companyLogo: 'https://via.placeholder.com/100/0000FF/808080?text=D',
        // Example logo URL
        tags: ['SQL', 'Python', '数据可视化', '金融'],
        hrName: '陈女士',
        location: '上海·浦东新区',
        workExperience: '3-5年',
        education: '本科',
        benefits: ['五险一金', '年底双薪', '带薪年假', '定期体检'],
        description: '负责业务数据的提取、清洗、分析与可视化，为决策提供支持...',
        requirements: ['熟练掌握SQL、Python', '熟悉常用数据分析模型', '良好的沟通能力'],
        status: 'active',
        // Example status
        date: '2023-10-26',
        // Example date string
        interviewTime: null,
        isFavorite: false,
      ),
      Job(
        id: 'j002',
        title: '产品经理 (AI 方向)',
        salary: '20-35K',
        company: '创业公司 E',
        companySize: '50-150人',
        companyLogo: 'https://via.placeholder.com/100/FF0000/FFFFFF?text=E',
        tags: ['AI', '产品设计', '用户研究', '需求分析'],
        hrName: '刘先生',
        location: '北京·海淀区',
        workExperience: '5-10年',
        education: '硕士及以上',
        benefits: ['股票期权', '弹性工作', '免费三餐', '团队氛围好'],
        description: '负责AI相关产品的规划、设计和迭代，推动产品落地...',
        requirements: ['对AI技术有深入理解', '具备成功的产品设计经验', '优秀的跨部门沟通能力'],
        status: 'active',
        date: '2023-10-25',
        interviewTime: null,
        isFavorite: true, // Example favorite
      ),
      Job(
        id: 'j003',
        title: '前端工程师 (React)',
        salary: '18-30K',
        company: '电商平台 F',
        companySize: '1000人以上',
        companyLogo: 'https://via.placeholder.com/100/008000/FFFFFF?text=F',
        tags: ['React', 'JavaScript', 'TypeScript', '性能优化'],
        hrName: '孙小姐',
        location: '杭州·西湖区',
        workExperience: '3-5年',
        education: '本科',
        benefits: ['六险一金', '餐补', '交通补贴', '技术氛围浓厚'],
        description: '负责电商平台前端业务开发、性能优化和技术选型...',
        requirements: ['精通React及其生态', '熟悉前端工程化', '有大型项目经验者优先'],
        status: 'active',
        date: '2023-10-27',
        interviewTime: null,
        isFavorite: false,
      ),
      Job(
        id: 'j006',
        title: 'Flutter 开发工程师',
        salary: '15-28K',
        company: '移动应用 I',
        companySize: '150-500人',
        companyLogo: 'https://via.placeholder.com/100/FFA500/000000?text=I',
        tags: ['Flutter', 'Dart', '移动端', '性能优化'],
        hrName: '赵女士',
        location: '成都·高新区',
        workExperience: '1-3年',
        education: '本科',
        benefits: ['五险一金', '项目奖金', '零食下午茶', '定期团建'],
        description: '负责公司核心App的Flutter端开发与维护，性能优化...',
        requirements: ['熟悉Flutter及Dart语言', '有原生开发经验者优先', '良好的编码习惯'],
        status: 'active',
        date: '2023-10-24',
        interviewTime: null,
        isFavorite: true,
      ),
    ];

    if (tag == null || tag == '全部') {
      return allJobs;
    } else {
      return allJobs
          .where((job) =>
              job.title.toLowerCase().contains(tag.toLowerCase()) ||
              job.tags.any((t) => t.toLowerCase() == tag.toLowerCase()) ||
              tag == '附近')
          .toList();
    }
  }

  Future<List<String>> getRecommendationTags() async {
    // Replace with your actual API call to fetch tags
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    // Mock data:
    return ['全部', '附近', 'Java', '不限经验', 'Python', '产品经理', '应届生', 'Flutter'];
    // Example error simulation:
    // throw Exception("Failed to load tags from API");
  }

  Future<bool> toggleFavorite(String jobId, bool currentIsFavorite) async {
    try {
      String endpoint = 'job/favorite';

      Response response;

      response = await dio.post(
        endpoint,
        data: {'jobId': jobId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Favorite status toggled successfully for job $jobId');
        return true;
      } else {
        debugPrint(
            'Failed to toggle favorite: ${response.statusCode} ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('DioError toggling favorite for job $jobId: $e');
      return false;
    } catch (e) {
      debugPrint('Error toggling favorite for job $jobId: $e');
      return false;
    }
  }
}
