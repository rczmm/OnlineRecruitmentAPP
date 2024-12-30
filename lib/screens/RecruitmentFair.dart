import 'package:flutter/material.dart';

class RecruitmentFair {
  final String title;
  final String date;
  final String location;
  final String description;
  final String imageUrl;

  RecruitmentFair({
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.imageUrl,
  });
}

class RecruitmentFairPage extends StatelessWidget {
  final List<RecruitmentFair> fairs = [
    RecruitmentFair(
      title: '大型IT专场招聘会',
      date: '2024年3月15日 10:00-17:00',
      location: '北京国际会议中心',
      description: '汇集国内外知名IT企业，提供海量优质岗位。',
      imageUrl: 'https://via.placeholder.com/350x150', // 替换为真实图片URL
    ),
    RecruitmentFair(
      title: '高校毕业生春季招聘会',
      date: '2024年4月20日 9:00-16:00',
      location: '上海展览中心',
      description: '面向应届毕业生，提供实习和就业机会。',
      imageUrl: 'https://via.placeholder.com/350x150', // 替换为真实图片URL
    ),
    // 更多招聘会信息
    RecruitmentFair(
      title: '外贸行业专场招聘会',
      date: '2024年5月8日 9:00-16:00',
      location: '广州琶洲会展中心',
      description: '面向外贸行业人才，提供丰富的职业发展机会。',
      imageUrl: 'https://via.placeholder.com/350x150', // 替换为真实图片URL
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('招聘会信息'),
      ),
      body: ListView.builder(
        itemCount: fairs.length,
        itemBuilder: (context, index) {
          final fair = fairs[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: InkWell( // 添加点击效果
              onTap: () {
                // 点击卡片后的操作，例如跳转到详情页面
                print('点击了 ${fair.title}');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecruitmentFairDetailPage(fair:fair)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    fair.imageUrl,
                    fit: BoxFit.cover,
                    height: 150,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text('图片加载失败'));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fair.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(children: [
                          Icon(Icons.calendar_today, size: 16,),
                          SizedBox(width: 4,),
                          Text(fair.date),
                        ]),
                        SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.location_on, size: 16,),
                          SizedBox(width: 4,),
                          Text(fair.location),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class RecruitmentFairDetailPage extends StatelessWidget {
  final RecruitmentFair fair;
  const RecruitmentFairDetailPage({Key? key, required this.fair}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fair.title),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              fair.imageUrl,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text('图片加载失败'));
              },
            ),
            SizedBox(height: 20,),
            Text(fair.title,style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),
            Row(children: [
              Icon(Icons.calendar_today, size: 16,),
              SizedBox(width: 4,),
              Text(fair.date),
            ]),
            SizedBox(height: 10,),
            Row(children: [
              Icon(Icons.location_on, size: 16,),
              SizedBox(width: 4,),
              Text(fair.location),
            ]),
            SizedBox(height: 20,),
            Text(fair.description,style: TextStyle(fontSize: 16,),),
          ],
        ),
      ),
    );
  }
}