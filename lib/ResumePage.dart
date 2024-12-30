import 'package:flutter/material.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的简历'),
      ),
      body: SingleChildScrollView( // 为了内容超出屏幕时可以滚动
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('个人信息'),
            _buildPersonalInfo(),

            _buildSectionTitle('求职状态'),
            _buildJobStatus(),

            _buildSectionTitle('个人优势'),
            _buildPersonalStrengths(),

            _buildSectionTitle('求职期望'),
            _buildJobExpectations(),

            _buildSectionTitle('工作经历'),
            _buildWorkExperience(),

            _buildSectionTitle('项目经历'),
            _buildProjectExperience(),

            _buildSectionTitle('教育经历'),
            _buildEducationExperience(),

            _buildSectionTitle('所获荣誉'),
            _buildHonors(),

            _buildSectionTitle('资格证书'),
            _buildCertifications(),

            _buildSectionTitle('专业技能'),
            _buildSkills(),

            _buildSectionTitle('职业性格'),
            _buildPersonality(),
          ],
        ),
      ),
    );
  }

  // 构建section标题的通用方法
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  // 以下是各个部分的具体内容构建方法，需要根据实际情况填充数据

  Widget _buildPersonalInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('姓名：张三'),
        Text('电话：13800138000'),
        Text('邮箱：zhangsan@example.com'),
        Text('地址：北京市'),
        // 可以添加头像等
      ],
    );
  }

  Widget _buildJobStatus() {
    return const Text('目前正在积极寻找Java后端开发相关工作。');
  }

  Widget _buildPersonalStrengths() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• 扎实的Java基础，熟悉常用框架（Spring、MyBatis等）。'),
        Text('• 良好的编码习惯和团队合作精神。'),
        // ...
      ],
    );
  }

  Widget _buildJobExpectations() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('期望职位：Java后端开发工程师'),
        Text('期望地点：北京、上海'),
        Text('期望薪资：面议'),
      ],
    );
  }

  Widget _buildWorkExperience() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('XX公司  Java开发工程师  2020.07 - 至今'),
        Text('• 负责XXX项目的开发和维护。'),
        // ...
      ],
    );
  }

  Widget _buildProjectExperience() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('XXX项目  2021.01 - 2021.06'),
        Text('• 使用XXX技术完成了XXX功能。'),
        // ...
      ],
    );
  }

  Widget _buildEducationExperience() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('XX大学  计算机科学与技术  本科  2016.09 - 2020.06'),
      ],
    );
  }

  Widget _buildHonors() {
    return const Text('• 获得XX奖学金。');
  }

  Widget _buildCertifications() {
    return const Text('• 获得XXX认证。');
  }

  Widget _buildSkills() {
    return const Wrap( // 使用Wrap实现技能标签的自动换行
      spacing: 8.0, // 标签之间的水平间距
      runSpacing: 4.0, // 标签之间的垂直间距
      children: [
        Chip(label: Text('Java')),
        Chip(label: Text('Spring')),
        Chip(label: Text('MySQL')),
        // ...
      ],
    );
  }

  Widget _buildPersonality() {
    return const Text('• 具有较强的学习能力和适应能力，能够快速掌握新技术。');
  }
}