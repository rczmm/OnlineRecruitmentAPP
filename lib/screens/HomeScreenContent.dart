import 'package:flutter/material.dart';
import '../models/job.dart';
import 'home_screen.dart';

import 'package:dio/dio.dart';
import 'package:zhaopingapp/services/dio_client.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  int _page = 0;
  final int _pageSize = 10; // 设置每页加载的数据量
  List<Job> _allJobs = [];

  Future<List<Job>> _loadMoreJobs() async {
    try {
      final response = await dio.post(
        "job/list",
        data: {
          "title": "", // 稍后根据搜索框的值更新
          "company": "", // 稍后根据筛选条件更新
          "tag": "", // 稍后根据主 Tab 的选择更新
          "type": "",
          "pageNum": _page,
          "pageSize": _pageSize,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> jobList = response.data['data']['records'];
        final List<Job> newJobs =
            jobList.map((json) => Job.fromJson(json)).toList();
        setState(() {
          _allJobs.addAll(newJobs);
          _page++;
        });
        return newJobs;
      } else {
        // 可以返回一个空列表或者抛出异常，根据你的错误处理策略来决定
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('网络错误'),
              content: Text('请检查你的网络连接并重试。'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('确定'),
                ),
              ],
            );
          },
        );
        return [];
      }
    } on DioException catch (e) {
      // 处理 Dio 异常，例如网络连接错误
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('网络错误'),
            content: Text('请检查你的网络连接并重试。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('确定'),
              ),
            ],
          );
        },
      );
      return [];
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('网络错误'),
            content: Text('请检查你的网络连接并重试。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('确定'),
              ),
            ],
          );
        },
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return JobListContainer(onLoadMore: _loadMoreJobs);
  }
}
