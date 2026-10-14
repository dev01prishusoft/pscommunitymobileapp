import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/utils/token_manager.dart';
import 'package:pscommunitymobileapp/features/family/models/family_tree_model.dart';
import 'package:pscommunitymobileapp/features/family/repositories/family_repository.dart';
import 'package:pscommunitymobileapp/features/family/widgets/family_tree_layout.dart';

class FamilyTreeController extends GetxController {
  FamilyTreeController({this.initialMemberId});

  final int? initialMemberId;
  int? currentMemberId;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<FamilyTreeData> treeData = Rxn<FamilyTreeData>();
  final Rxn<FamilyTreeNode> selectedMember = Rxn<FamilyTreeNode>();

  final RxSet<int> collapsedNodeIds = <int>{}.obs;

  late final TransformationController transformationController;

  @override
  void onInit() {
    super.onInit();
    transformationController = TransformationController();

    int? memberId = initialMemberId;
    if (memberId == null && Get.arguments is Map) {
      memberId = Get.arguments['memberId'] as int?;
    }
    if (memberId == null || memberId <= 0) {
      if (Get.isRegistered<TokenManager>()) {
        memberId = Get.find<TokenManager>().memberId;
      }
    }
    currentMemberId = memberId;
    loadFamilyTree(memberId: memberId);
  }

  @override
  void onClose() {
    transformationController.dispose();
    super.onClose();
  }

  Future<void> loadFamilyTree({int? memberId}) async {
    final int? targetMemberId = memberId ?? currentMemberId;
    if (targetMemberId != null && targetMemberId > 0) {
      currentMemberId = targetMemberId;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (targetMemberId != null && targetMemberId > 0) {
        final repository = Get.find<FamilyRepository>();
        final data = await repository.getFamilyTree(targetMemberId);
        if (data != null && data.head != null) {
          treeData.value = data;
        } else {
          errorMessage.value = LK.Nofamilytreerecordsfound.tr;
          treeData.value = null;
        }
      } else {
        errorMessage.value = LK.Memberinformationnotprovided.tr;
        treeData.value = null;
      }
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'FamilyTreeController.loadFamilyTree failed',
      );
      errorMessage.value = LK.Failedtoloadfamilytreetryagain.tr;
      treeData.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleBranchCollapse(int memberId) {
    if (collapsedNodeIds.contains(memberId)) {
      collapsedNodeIds.remove(memberId);
    } else {
      collapsedNodeIds.add(memberId);
    }
  }

  void expandAll() {
    collapsedNodeIds.clear();
  }

  void zoomIn() {
    final Matrix4 current = transformationController.value;
    final double scale = current.getMaxScaleOnAxis();
    if (scale < 2.5) {
      transformationController.value =
          current.clone()..scaleByDouble(1.2, 1.2, 1.0, 1.0);
    }
  }

  void zoomOut() {
    final Matrix4 current = transformationController.value;
    final double scale = current.getMaxScaleOnAxis();
    if (scale > 0.3) {
      transformationController.value =
          current.clone()..scaleByDouble(0.8, 0.8, 1.0, 1.0);
    }
  }

  void selectMember(FamilyTreeNode member) {
    selectedMember.value = member;
  }

  FamilyTreeComputedLayout? getComputedLayout() {
    final root = treeData.value?.head;
    if (root == null) return null;

    return FamilyTreeComputedLayout.compute(
      root: root,
      collapsedNodeIds: collapsedNodeIds.toSet(),
    );
  }
}
