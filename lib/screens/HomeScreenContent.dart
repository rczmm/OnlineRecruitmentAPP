import 'package:flutter/material.dart';
import '../models/job.dart';
import 'job_list_container.dart';
import 'package:dio/dio.dart';
import 'package:zhaopingapp/services/dio_client.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  int _page = 1;
  final int _pageSize = 10; // 设置每页加载的数据量
  List<Job> _allJobs = [];
  String _currentType = ''; // 保存当前选中的关键词
  String _currentTag = '';

  Future<List<Job>> _loadMoreJobs(String? type, String? tag) async {
    print("开始加载更多职位");
    print("当前页码 _page: $_page");
    print("传入的 type: $type");
    print("传入的 tag: $tag");
    try {
      final response = await dio.post(
        "job/list",
        data: {
          "keyword": "",
          "tag": tag ?? _currentTag,
          "type": type ?? _currentType,
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
          if (newJobs.isNotEmpty) {
            _page++;
          }
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
    } on DioException {
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

  // 添加这个方法来处理下拉刷新
  Future<List<Job>> _refreshJobs(String? type, String? tag) async {
    setState(() {
      _page = 1;
      _allJobs.clear();
      if (type != null) {
        _currentTag = tag!;
        _currentType = type;
      }
    });
    return await _loadMoreJobs(type, tag);
  }

  @override
  Widget build(BuildContext context) {
    return JobListContainer(
      onLoadMore: _loadMoreJobs,
      onRefresh: _refreshJobs,
    );
  }
}
