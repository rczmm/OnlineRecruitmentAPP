import 'package:flutter/material.dart';
import '../models/job.dart';
import 'home_screen.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  List<Job> _loadMoreJobs() {
    // 使用示例数据
    return _generateSampleJobs();
  }

  @override
  Widget build(BuildContext context) {
    return JobListContainer(onLoadMore: _loadMoreJobs);
  }

  List<Job> _generateSampleJobs() {
    final titles = [
      '高级Java开发工程师',
      'Flutter移动开发工程师',
      'Python数据分析师',
      '前端开发工程师',
      'DevOps工程师',
      '产品经理',
      'UI设计师',
      '算法工程师',
      '测试工程师',
      '运维工程师'
    ];

    final companies = [
      {'name': '字节跳动', 'size': '10000人以上'},
      {'name': '腾讯科技', 'size': '10000人以上'},
      {'name': '阿里巴巴', 'size': '10000人以上'},
      {'name': '美团点评', 'size': '10000人以上'},
      {'name': '快手科技', 'size': '5000-10000人'},
      {'name': '小米科技', 'size': '5000-10000人'},
      {'name': '京东集团', 'size': '10000人以上'},
      {'name': '网易', 'size': '5000-10000人'},
      {'name': '百度', 'size': '10000人以上'},
      {'name': '滴滴出行', 'size': '5000-10000人'}
    ];

    final salaries = [
      '15k-25k',
      '20k-35k',
      '25k-45k',
      '30k-50k',
      '35k-60k',
      '40k-70k',
      '45k-80k',
      '50k-90k',
      '60k-100k',
      '面议'
    ];

    final locations = [
      '北京市朝阳区',
      '上海市浦东新区',
      '深圳市南山区',
      '广州市天河区',
      '杭州市西湖区',
      '成都市高新区',
      '武汉市洪山区',
      '南京市江宁区',
      '西安市雁塔区',
      '苏州市工业园区'
    ];

    final allTags = {
      '开发': [
        'Java',
        'Spring Boot',
        'MySQL',
        'Redis',
        'MQ',
        'Flutter',
        'Python',
        'Django',
        'React',
        'Vue.js',
        'Node.js',
        'TypeScript',
        'Docker',
        'K8s',
        'AWS'
      ],
      '设计': ['UI设计', 'UE设计', 'Figma', 'Sketch', 'PhotoShop', '原型设计', '交互设计'],
      '产品': ['需求分析', '产品规划', '用户研究', '数据分析', 'Axure', '项目管理'],
      '算法': ['机器学习', '深度学习', 'NLP', '计算机视觉', 'PyTorch', 'TensorFlow']
    };

    final hrNames = [
      '王女士',
      '李先生',
      '张女士',
      '刘先生',
      '陈女士',
      '赵先生',
      '孙女士',
      '周先生',
      '吴女士',
      '郑先生'
    ];

    return List.generate(10, (index) {
      final company = companies[index];
      final title = titles[index];
      String category = '';
      if (title.contains('开发'))
        category = '开发';
      else if (title.contains('设计'))
        category = '设计';
      else if (title.contains('产品'))
        category = '产品';
      else if (title.contains('算法'))
        category = '算法';
      else
        category = '开发';

      final tagPool = allTags[category] ?? allTags['开发']!;
      final selectedTags = (tagPool.toList()..shuffle()).take(3).toList();

      return Job(
          id: 'job_${index + 1}',
          title: title,
          salary: salaries[index],
          company: company['name']!,
          companySize: company['size']!,
          tags: selectedTags,
          hrName: hrNames[index],
          location: locations[index],
          workExperience: '3-5年',
          education: '本科及以上',
          benefits: ['五险一金', '年终奖', '带薪年假', '加班补助'],
          description: '负责公司核心业务系统的开发和维护工作',
          requirements: ['本科及以上学历', '3年以上相关工作经验', '良好的团队协作能力'],
          status: '未投递',
          date: DateTime.now().toString().substring(0, 10));
    });
  }

}