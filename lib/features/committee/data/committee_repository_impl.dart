import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/utils/date_formatter.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/domain/repositories/committee_repository.dart';
class CommitteeRepositoryImpl implements CommitteeRepository {
  CommitteeRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<List<CommitteeNode>>> getCommittees({
    String? searchQuery,
    int pageNumber = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  }) async {
    final Map<String, dynamic> params = {
      'PageNumber': pageNumber,
      'PageSize': pageSize,
    };

    if (searchQuery != null && searchQuery.isNotEmpty) {
      params['Search'] = searchQuery;
    }

    final result = await _apiClient.getPaginated<CommitteeNode>(
      ApiEndpoints.committees,
      queryParameters: params,
      cancelToken: cancelToken,
      listKey: 'committees',
      fromJsonT: (json) =>
          CommitteeNode.fromJson(json as Map<String, dynamic>),
    );

    if (result is Success<PaginatedResponse<CommitteeNode>>) {
      final list = result.data.data;
      final tree = _buildTree(list);

      if (kDebugMode) {
        for (var root in tree) {
          _printNode(root, 0);
        }
      }

      return Success(tree);
    } else {
      return Error((result as Error).failure);
    }
  }

  @override
  Future<Result<CommitteeDetail?>> getCommitteeDetail(int id, {CancelToken? cancelToken}) async {
    final result = await _apiClient.getParsed<CommitteeDetail>(
      '${ApiEndpoints.committeeDetail}/$id',
      cancelToken: cancelToken,
      fromJsonT: (json) =>
          CommitteeDetail.fromJson(json as Map<String, dynamic>),
    );

    if (result is Success<ApiResponse<CommitteeDetail>>) {
      final detail = result.data.data;
      if (detail != null) {
        try {
          final membersResult = await _apiClient.getParsed<List<CommitteeMember>>(
            '/api/v1/CommitteeMember/by-committee/$id',
            cancelToken: cancelToken,
            fromJsonT: (json) => (json as List)
                .map((e) => CommitteeMember.fromJson(e as Map<String, dynamic>))
                .toList(),
          );
          if (membersResult is Success<ApiResponse<List<CommitteeMember>>>) {
            final fetchedMembers = membersResult.data.data ?? [];
            final activeMembers = fetchedMembers.where((m) => !isDateInPast(m.endDate)).toList();
            return Success(detail.copyWith(members: activeMembers));
          }
        } catch (_) {}
      }
      return Success(detail);
    } else {
      return Error((result as Error).failure);
    }
  }

  void _printNode(CommitteeNode node, int depth) {
    for (var child in node.children) {
      _printNode(child, depth + 1);
    }
  }

  List<CommitteeNode> _buildTree(List<CommitteeNode> flatList) {
    final Map<int, CommitteeNode> allNodes = {for (var n in flatList) n.id: n};
    final List<CommitteeNode> roots = [];
    final Map<int, List<CommitteeNode>> childrenMap = {};

    for (var node in flatList) {
      final pId = node.parentId;
      if (pId == null ||
          pId == 0 ||
          !allNodes.containsKey(pId) ||
          pId == node.id) {
        roots.add(node);
      } else {
        childrenMap.putIfAbsent(pId, () => []).add(node);
      }
    }
    CommitteeNode link(CommitteeNode node) {
      final children = childrenMap[node.id] ?? [];
      if (children.isEmpty) return node;

      return node.copyWith(children: children.map((c) => link(c)).toList());
    }

    final tree = roots.map((r) => link(r)).toList();

    if (kDebugMode) {
      for (var root in tree) {
        _printNode(root, 0);
      }
    }

    return tree;
  }
}
