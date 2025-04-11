import 'package:flutter/material.dart';
import 'package:zhaopingapp/features/jobs/data/models/job_model.dart';
import 'job_list_container.dart';
import 'package:dio/dio.dart';
import 'package:zhaopingapp/core/network/dio_client.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  // Remove state variables managed by JobListView
  // int _page = 1; // Managed by JobListView
  // final List<Job> _allJobs = []; // Managed by JobListView
  // String _currentType = ''; // Passed as argument
  // String _currentTag = ''; // Passed as argument

  final int _pageSize = 10; // Keep page size configuration here
  CancelToken? _cancelToken; // Keep cancel token logic

  @override
  void dispose() {
    _cancelPreviousRequest(); // Cancel any ongoing request when the widget is disposed
    super.dispose();
  }

  void _showErrorDialog(String message) {
    // Check if the widget is still mounted before showing a dialog
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

  // --- Updated _loadMoreJobs ---
  // Now accepts the page number from JobListView
  Future<List<Job>> _loadMoreJobs(String? type, String? tag, int page) async {
    _cancelPreviousRequest(); // Cancel any previous request before starting a new one
    _cancelToken = CancelToken();

    try {
      final response = await dio.post(
        "job/list", // Ensure this endpoint is correct
        data: {
          "keyword": "", // Assuming keyword is handled elsewhere (e.g., search screen)
          "tag": tag ?? "", // Use provided tag or default
          "type": type ?? "", // Use provided type or default
          "pageNum": page, // Use the page number passed by JobListView
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
      _showErrorDialog('发生意外错误：$e');
      return []; // Return empty list on failure
    }
  }

  Future<List<Job>> _refreshJobs(String? type, String? tag) async {
    return await _loadMoreJobs(type, tag, 1);
  }

  // Method to cancel the previous request
  void _cancelPreviousRequest() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('New request started');
    }
    _cancelToken = null; // Ensure token is nullified after cancellation attempt
  }

  @override
  Widget build(BuildContext context) {
    // Pass the updated functions to JobListContainer
    return JobListContainer(
      onLoadMore: _loadMoreJobs, // Now matches the expected signature
      onRefresh: _refreshJobs,
    );
  }
}