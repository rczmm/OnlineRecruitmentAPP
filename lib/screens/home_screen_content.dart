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
  final List<Job> _allJobs = [];
  String _currentType = ''; // 保存当前选中的关键词
  String _currentTag = '';
  CancelToken? _cancelToken;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('网络错误'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Future<List<Job>> _loadMoreJobs(String? type, String? tag) async {
    try {
      // 如果type或tag发生变化，重置页码
      if ((type != null && type != _currentType) ||
          (tag != null && tag != _currentTag)) {
        _cancelPreviousRequest();
        _page = 1;
        _allJobs.clear();
        _currentType = type ?? _currentType;
        _currentTag = tag ?? _currentTag;
      }

      _cancelToken = CancelToken();

      final response = await dio.post(
        "job/list",
        data: {
          "keyword": "",
          "tag": tag ?? _currentTag,
          "type": type ?? _currentType,
          "pageNum": _page,
          "pageSize": _pageSize,
        },
        cancelToken: _cancelToken,
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
        _showErrorDialog('请检查你的网络连接并重试。');
        return [];
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        // 请求被取消，不需要处理
        return [];
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        // 处理超时异常，例如显示错误消息
        _showErrorDialog('网络连接超时，请检查你的网络连接并重试。');
        return [];
      } else if (e.type == DioExceptionType.badResponse) {
        // 处理响应错误，例如服务器返回错误码
        _showErrorDialog('服务器错误，请稍后重试。');
        return [];
      } else {
        // 处理 Dio 异常，例如网络连接错误
        _showErrorDialog('请检查你的网络连接并重试。');
        return [];
      }
    } catch (e) {
      _showErrorDialog('发生错误：$e');
      return [];
    }
  }

  // 添加一个方法来取消之前的请求
  void _cancelPreviousRequest() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('用户取消了之前的请求');
      _cancelToken = null; // 重置 CancelToken
    }
  }

  // 添加这个方法来处理下拉刷新
  Future<List<Job>> _refreshJobs(String? type, String? tag) async {
    setState(() {
      _cancelPreviousRequest(); // 取消之前的请求
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
