import 'package:pscommunitymobileapp/core/models/committee_node.dart';
import 'package:pscommunitymobileapp/core/models/committee_detail.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:dio/dio.dart';

abstract class CommitteeRepository {
  Future<Result<List<CommitteeNode>>> getCommittees({
    String? searchQuery,
    int pageNumber = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  });
  Future<Result<CommitteeDetail?>> getCommitteeDetail(int id, {CancelToken? cancelToken});
}
