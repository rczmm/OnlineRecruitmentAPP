import 'package:dio/dio.dart';
import 'package:zhaopingapp/core/errors/exceptions.dart';
import 'package:zhaopingapp/core/network/api_constants.dart';
import 'package:zhaopingapp/models/job.dart';

class JobRepository {
  final Dio _dio;

  JobRepository(this._dio);

  Future<List<Job>> fetchJobs({
    String? type,
    String? tag,
    required int page,
    required int pageSize,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.jobList, // Use constant
        data: {
          ApiRequestKeys.keyword: "",
          ApiRequestKeys.tag: tag ?? "",
          ApiRequestKeys.type: type ?? "",
          ApiRequestKeys.pageNum: page,
          ApiRequestKeys.pageSize: pageSize,
        },
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> jobList = response.data['data']?['records'] ?? [];
        return jobList.map((json) => Job.fromJson(json)).toList();
      } else {
        throw ApiException(response.data?['message'] ?? 'Failed to load jobs',
            response.data?['code']);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      } else {
        throw NetworkException.fromDioError(e);
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
