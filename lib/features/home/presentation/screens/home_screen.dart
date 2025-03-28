import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:zhaopingapp/core/errors/exceptions.dart';
import 'package:zhaopingapp/core/network/dio_client.dart';
import 'package:zhaopingapp/features/jobs/data/repositories/job_repository.dart';
import 'package:zhaopingapp/features/jobs/data/models/job_model.dart';
import 'package:zhaopingapp/screens/job_list_container.dart'; // Make sure this path is correct

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _pageSize = 10;
  CancelToken? _cancelToken;
  late final JobRepository _jobRepository;


  @override
  void initState() {
    super.initState();
    _jobRepository = JobRepository(dio);
  }

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
      final newJobs = await _jobRepository.fetchJobs(
        type: type,
        tag: tag,
        page: page,
        pageSize: _pageSize,
        cancelToken: _cancelToken,
      );
      _cancelToken = null; // Clear token on success
      debugPrint('Loaded ${newJobs.length} jobs for page $page');
      return newJobs;
    } on ApiException catch (e) {
      _cancelToken = null;
      _showErrorDialog('API Error (${e.code}): ${e.message}');
      return [];
    } on NetworkException catch (e) {
      _cancelToken = null;
      _showErrorDialog(
          e.friendlyMessage);
      return [];
    } on DioException catch (e) {
      _cancelToken = null;
      if (e.type == DioExceptionType.cancel) {
        debugPrint('Request cancelled: Type: $type, Tag: $tag, Page: $page');
        return [];
      } else {
        _showErrorDialog('网络请求失败，请重试。');
        return [];
      }
    } catch (e) {
      _cancelToken = null;
      debugPrint('Error loading page $page: $e');
      _showErrorDialog('发生意外错误。');
      return [];
    }
  }

  Future<List<Job>> _refreshJobs(String? type, String? tag) async {
    debugPrint('Refreshing jobs - Type: $type, Tag: $tag');
    return await _loadMoreJobs(type, tag, 1);
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
