import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:zhaopingapp/core/network/dio_client.dart';
import 'package:zhaopingapp/models/job.dart';
import 'package:zhaopingapp/screens/job_list_container.dart'; // Make sure this path is correct

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _pageSize = 10;
  CancelToken? _cancelToken;

  @override
  void dispose() {
    _cancelPreviousRequest();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
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

  Future<List<Job>> _loadMoreJobs(String? type, String? tag, int page) async {
    _cancelPreviousRequest();
    _cancelToken = CancelToken();

    debugPrint('Loading jobs - Type: $type, Tag: $tag, Page: $page');

    try {
      final response = await dio.post(
        "job/list",
        data: {
          "keyword": "",
          "tag": tag ?? "",
          "type": type ?? "",
          "pageNum": page,
          "pageSize": _pageSize,
        },
        cancelToken: _cancelToken,
      );

      _cancelToken = null; // Clear token after request completes or fails

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> jobList = response.data['data']?['records'] ?? [];
        final List<Job> newJobs =
            jobList.map((json) => Job.fromJson(json)).toList();
        // DO NOT call setState here to update _allJobs or _page
        // Just return the fetched jobs for the current page
        debugPrint('Loaded ${newJobs.length} jobs for page $page');
        return newJobs;
      } else {
        // Handle API error response
        final errorMsg = response.data?['message'] ?? 'Failed to load jobs';
        _showErrorDialog('API Error: $errorMsg');
        return []; // Return empty list on failure
      }
    } on DioException catch (e) {
      _cancelToken = null; // Clear token on error
      if (e.type == DioExceptionType.cancel) {
        debugPrint('Request cancelled: Type: $type, Tag: $tag, Page: $page');
        return []; // Request was cancelled, return empty list
      } else {
        // Handle other Dio errors
        String errorMessage;
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            errorMessage = '网络连接超时，请检查你的网络连接并重试。';
            break;
          case DioExceptionType.badResponse:
            errorMessage = '服务器错误 (${e.response?.statusCode})，请稍后重试。';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '网络连接错误，请检查你的网络设置。';
            break;
          default:
            errorMessage = '网络请求失败，请重试。';
        }
        debugPrint('DioError loading page $page: $e');
        _showErrorDialog(errorMessage);
        return []; // Return empty list on failure
      }
    } catch (e) {
      _cancelToken = null; // Clear token on error
      debugPrint('Error loading page $page: $e');
      _showErrorDialog('发生意外错误：$e');
      return []; // Return empty list on failure
    }
  }

  // --- Updated _refreshJobs ---
  // This function is called by JobListView's RefreshIndicator
  // It should fetch the *first* page of data.
  Future<List<Job>> _refreshJobs(String? type, String? tag) async {
    // No need to manage state like _page or _allJobs here.
    // Just call _loadMoreJobs with page = 1.
    // Cancellation is handled within _loadMoreJobs.
    debugPrint('Refreshing jobs - Type: $type, Tag: $tag');
    return await _loadMoreJobs(type, tag, 1); // Always load page 1 on refresh
  }

  void _cancelPreviousRequest() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('New request started');
      debugPrint('Previous request cancelled.');
    }
    _cancelToken = null;
  }

  @override
  Widget build(BuildContext context) {
    return JobListContainer(
      onLoadMore: _loadMoreJobs,
      onRefresh: _refreshJobs,
    );
  }
}
