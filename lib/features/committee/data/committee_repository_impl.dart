import 'package:flutter/foundation.dart';
import 'package:pscommunitymobileapp/core/constants/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/committee/domain/repositories/committee_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_node.dart';
import 'package:pscommunitymobileapp/features/committee/domain/entities/committee_detail.dart';

class CommitteeRepositoryImpl implements CommitteeRepository {
  CommitteeRepositoryImpl(this._apiClient);
  
  final ApiClient _apiClient;

  @override
  Future<List<CommitteeNode>> getCommittees({
    String? searchQuery,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        params['Search'] = searchQuery;
      }

      final response = await _apiClient.get(
        ApiEndpoints.committees,
        queryParameters: params,
      );

      final json = response.data as Map<String, dynamic>;
      if (json['succeeded'] != true) return [];

      final dataObj = json['data'] as Map<String, dynamic>? ?? {};
      final list = dataObj['committees'] as List? ?? [];

      if (kDebugMode && list.isNotEmpty) {
        print('RAW COMMITTEE DATA SAMPLE: ${list.first}');
      }

      final allNodes = list
          .map((e) => CommitteeNode.fromJson(e as Map<String, dynamic>))
          .toList();

      final tree = _buildTree(allNodes);

      if (kDebugMode) {
        for (var root in tree) {
          _printNode(root, 0);
        }
      }

      return tree;
    } on Exception catch (e) {
      AppLogger.e('GetCommittees Error', e);
      rethrow;
    }
  }

  @override
  Future<CommitteeDetail?> getCommitteeDetail(int id) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.committeeDetail}/$id',
      );

      final json = response.data as Map<String, dynamic>;
      if (json['succeeded'] != true) return null;

      final dataObj = json['data'] as Map<String, dynamic>? ?? {};
      return CommitteeDetail.fromJson(dataObj);
    } on Exception catch (e) {
      AppLogger.e('GetCommitteeDetail Error', e);
      rethrow;
    }
  }

  void _printNode(CommitteeNode node, int depth) {
    print(
      '${"  " * depth}Node: ${node.name} (ID: ${node.id}, Parent: ${node.parentId}, Children: ${node.children.length})',
    );
    for (var child in node.children) {
      _printNode(child, depth + 1);
    }
  }

  List<CommitteeNode> _buildTree(List<CommitteeNode> flatList) {
    // 1. Map all nodes by ID for fast lookup
    final Map<int, CommitteeNode> allNodes = {for (var n in flatList) n.id: n};

    // 2. Map parents to their children
    final List<CommitteeNode> roots = [];
    final Map<int, List<CommitteeNode>> childrenMap = {};

    for (var node in flatList) {
      final pId = node.parentId;
      // Root check: null parent, zero parent, parent doesn't exist in list, or self-parent
      if (pId == null ||
          pId == 0 ||
          !allNodes.containsKey(pId) ||
          pId == node.id) {
        roots.add(node);
      } else {
        childrenMap.putIfAbsent(pId, () => []).add(node);
      }
    }

    // 3. Recursively link children using copyWith
    CommitteeNode link(CommitteeNode node) {
      final children = childrenMap[node.id] ?? [];
      if (children.isEmpty) return node;

      return node.copyWith(children: children.map((c) => link(c)).toList());
    }

    final tree = roots.map((r) => link(r)).toList();

    if (kDebugMode) {
      print('COMMITTEE HIERARCHY BUILT: ${tree.length} roots');
      for (var root in tree) {
        _printNode(root, 0);
      }
    }

    return tree;
  }
}
