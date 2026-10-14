import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/family/models/family_tree_model.dart';
import 'package:pscommunitymobileapp/features/family/widgets/family_member_card.dart';

class FamilyTreeLayoutConfig {
  static const double cardWidth = 144.0;
  static const double cardHeight = 184.0;
  static const double partnerGap = 32.0;
  static const double siblingGap = 42.0;
  static const double levelGap = 78.0;
  static const double canvasPadding = 48.0;
}

class MeasuredTreeNode {
  MeasuredTreeNode({
    required this.node,
    required this.nodeWidth,
    required this.subtreeWidth,
    required this.childrenTotalWidth,
    required this.children,
    required this.isCollapsed,
  });

  final FamilyTreeNode node;
  final double nodeWidth;
  final double subtreeWidth;
  final double childrenTotalWidth;
  final List<MeasuredTreeNode> children;
  final bool isCollapsed;
}

class PositionedCardData {
  PositionedCardData({
    required this.member,
    required this.rect,
    required this.isPartner,
  });

  final FamilyTreeNode member;
  final Rect rect;
  final bool isPartner;
}

class TreeConnectionLine {
  TreeConnectionLine({
    required this.start,
    required this.end,
    this.isPartnerConnector = false,
  });

  final Offset start;
  final Offset end;
  final bool isPartnerConnector;
}

class CoupleBridgeData {
  CoupleBridgeData({
    required this.center,
  });

  final Offset center;
}

class BranchToggleData {
  BranchToggleData({
    required this.memberId,
    required this.center,
    required this.childCount,
    required this.isCollapsed,
  });

  final int memberId;
  final Offset center;
  final int childCount;
  final bool isCollapsed;
}

class FamilyTreeComputedLayout {
  FamilyTreeComputedLayout({
    required this.cards,
    required this.lines,
    required this.coupleBridges,
    required this.branchToggles,
    required this.totalSize,
  });

  final List<PositionedCardData> cards;
  final List<TreeConnectionLine> lines;
  final List<CoupleBridgeData> coupleBridges;
  final List<BranchToggleData> branchToggles;
  final Size totalSize;

  static FamilyTreeComputedLayout compute({
    required FamilyTreeNode root,
    required Set<int> collapsedNodeIds,
  }) {
    const double cardW = FamilyTreeLayoutConfig.cardWidth;
    const double cardH = FamilyTreeLayoutConfig.cardHeight;
    const double partnerG = FamilyTreeLayoutConfig.partnerGap;
    const double siblingG = FamilyTreeLayoutConfig.siblingGap;
    const double levelG = FamilyTreeLayoutConfig.levelGap;
    const double pad = FamilyTreeLayoutConfig.canvasPadding;

    // Pass 1: Measure
    MeasuredTreeNode measure(FamilyTreeNode node) {
      final bool hasPartner = node.partner != null;
      final double nodeW = hasPartner ? (2 * cardW + partnerG) : cardW;
      final bool isCollapsed = collapsedNodeIds.contains(node.memberId);

      final measuredChildren = <MeasuredTreeNode>[];
      if (!isCollapsed && node.children.isNotEmpty) {
        for (final child in node.children) {
          measuredChildren.add(measure(child));
        }
      }

      double childrenW = 0;
      if (measuredChildren.isNotEmpty) {
        for (int i = 0; i < measuredChildren.length; i++) {
          childrenW += measuredChildren[i].subtreeWidth;
          if (i > 0) childrenW += siblingG;
        }
      }

      final double subtreeW = max(nodeW, childrenW);
      return MeasuredTreeNode(
        node: node,
        nodeWidth: nodeW,
        subtreeWidth: subtreeW,
        childrenTotalWidth: childrenW,
        children: measuredChildren,
        isCollapsed: isCollapsed,
      );
    }

    final measuredRoot = measure(root);

    final cards = <PositionedCardData>[];
    final lines = <TreeConnectionLine>[];
    final bridges = <CoupleBridgeData>[];
    final toggles = <BranchToggleData>[];

    double maxBottom = 0;

    // Pass 2: Position
    void position({
      required MeasuredTreeNode measured,
      required double left,
      required double top,
    }) {
      final node = measured.node;
      final double coupleX =
          left + (measured.subtreeWidth - measured.nodeWidth) / 2;
      final double coupleY = top;

      // 1. Primary Member Card Rect
      final memberRect = Rect.fromLTWH(coupleX, coupleY, cardW, cardH);
      cards.add(
        PositionedCardData(
          member: node,
          rect: memberRect,
          isPartner: false,
        ),
      );

      if (memberRect.bottom > maxBottom) {
        maxBottom = memberRect.bottom;
      }

      Offset stemStart;

      if (node.partner != null) {
        // 2. Partner Card Rect
        final double partnerX = coupleX + cardW + partnerG;
        final partnerRect = Rect.fromLTWH(partnerX, coupleY, cardW, cardH);
        cards.add(
          PositionedCardData(
            member: node.partner!,
            rect: partnerRect,
            isPartner: true,
          ),
        );

        // Horizontal line between partners
        final double partnerLineY = coupleY + cardH * 0.52;
        final lineStart = Offset(memberRect.right, partnerLineY);
        final lineEnd = Offset(partnerRect.left, partnerLineY);
        lines.add(
          TreeConnectionLine(
            start: lineStart,
            end: lineEnd,
            isPartnerConnector: true,
          ),
        );

        final bridgeCenter =
            Offset(coupleX + cardW + partnerG / 2, partnerLineY);
        bridges.add(CoupleBridgeData(center: bridgeCenter));

        // Outgoing line drops from partner line center
        stemStart = bridgeCenter;
      } else {
        // Single parent: line drops from bottom center
        stemStart = Offset(coupleX + cardW / 2, coupleY + cardH);
      }

      // Branch Toggle Pill if node has children
      if (node.children.isNotEmpty) {
        toggles.add(
          BranchToggleData(
            memberId: node.memberId,
            center: Offset(stemStart.dx, coupleY + cardH + 12),
            childCount: node.children.length,
            isCollapsed: measured.isCollapsed,
          ),
        );
      }

      // 3. Children placement
      if (measured.children.isNotEmpty) {
        final double branchY = coupleY + cardH + levelG * 0.5;
        final double childTop = coupleY + cardH + levelG;

        // Vertical stem down to horizontal distribution branch line
        lines.add(
          TreeConnectionLine(
            start: stemStart,
            end: Offset(stemStart.dx, branchY),
          ),
        );

        double childLeft =
            left + (measured.subtreeWidth - measured.childrenTotalWidth) / 2;
        final childEntryXs = <double>[];

        for (final childMeasured in measured.children) {
          final double childCoupleX = childLeft +
              (childMeasured.subtreeWidth - childMeasured.nodeWidth) / 2;
          // Drop line enters top-center of primary child card
          final double entryX = childCoupleX + cardW / 2;
          childEntryXs.add(entryX);

          // Vertical drop line to child top
          lines.add(
            TreeConnectionLine(
              start: Offset(entryX, branchY),
              end: Offset(entryX, childTop),
            ),
          );

          // Recurse
          position(
            measured: childMeasured,
            left: childLeft,
            top: childTop,
          );

          childLeft += childMeasured.subtreeWidth + siblingG;
        }

        // Horizontal distribution bar
        if (childEntryXs.isNotEmpty) {
          double minX = childEntryXs.first;
          double maxX = childEntryXs.last;
          if (stemStart.dx < minX) minX = stemStart.dx;
          if (stemStart.dx > maxX) maxX = stemStart.dx;

          lines.add(
            TreeConnectionLine(
              start: Offset(minX, branchY),
              end: Offset(maxX, branchY),
            ),
          );
        }
      }
    }

    position(
      measured: measuredRoot,
      left: pad,
      top: pad,
    );

    final totalWidth = measuredRoot.subtreeWidth + 2 * pad;
    final totalHeight = maxBottom + pad;

    return FamilyTreeComputedLayout(
      cards: cards,
      lines: lines,
      coupleBridges: bridges,
      branchToggles: toggles,
      totalSize: Size(totalWidth, totalHeight),
    );
  }
}

class FamilyTreeLinesPainter extends CustomPainter {
  FamilyTreeLinesPainter({
    required this.lines,
  });

  final List<TreeConnectionLine> lines;

  @override
  void paint(Canvas canvas, Size size) {
    final branchPaint = Paint()
      ..color = AppColors.treeBranchLine
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final partnerPaint = Paint()
      ..color = AppColors.treeSpouse.withValues(alpha: 0.6)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppColors.treeSlateMuted
      ..style = PaintingStyle.fill;

    for (final line in lines) {
      final paint = line.isPartnerConnector ? partnerPaint : branchPaint;
      canvas.drawLine(line.start, line.end, paint);

      // Draw subtle dot at junctions for tree clarity
      if (!line.isPartnerConnector && line.start.dx == line.end.dx) {
        // Vertical drop end point
        canvas.drawCircle(line.end, 2.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FamilyTreeLinesPainter oldDelegate) {
    return oldDelegate.lines != lines;
  }
}

class FamilyTreeCanvasWidget extends StatelessWidget {
  const FamilyTreeCanvasWidget({
    super.key,
    required this.layout,
    required this.onCardTap,
    required this.onToggleBranch,
    this.selectedMemberId,
  });

  final FamilyTreeComputedLayout layout;
  final void Function(FamilyTreeNode member) onCardTap;
  final void Function(int memberId) onToggleBranch;
  final int? selectedMemberId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: layout.totalSize.width,
      height: layout.totalSize.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Connecting Lines
          CustomPaint(
            size: layout.totalSize,
            painter: FamilyTreeLinesPainter(lines: layout.lines),
          ),

          // Couple Heart / Rings Bridges
          for (final bridge in layout.coupleBridges)
            Positioned(
              left: bridge.center.dx - 11,
              top: bridge.center.dy - 11,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  border: Border.all(
                    color: AppColors.treeSpouse,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.treeSpouse.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 11,
                    color: AppColors.treeSpouse,
                  ),
                ),
              ),
            ),

          // Branch Collapse / Expand Toggle Badges
          for (final toggle in layout.branchToggles)
            Positioned(
              left: toggle.center.dx - 18.w,
              top: toggle.center.dy - 10.h,
              child: InkWell(
                onTap: () => onToggleBranch(toggle.memberId),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.treeBranchLine,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        toggle.isCollapsed
                            ? Icons.add_circle_outline_rounded
                            : Icons.remove_circle_outline_rounded,
                        size: 11.sp,
                        color: AppColors.treeSlateLight,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${toggle.childCount}',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.treeSlateLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Member Cards
          for (final card in layout.cards)
            Positioned(
              left: card.rect.left,
              top: card.rect.top,
              child: FamilyMemberCard(
                member: card.member,
                width: card.rect.width,
                height: card.rect.height,
                isSelected: selectedMemberId == card.member.memberId,
                onTap: () => onCardTap(card.member),
              ),
            ),
        ],
      ),
    );
  }
}
