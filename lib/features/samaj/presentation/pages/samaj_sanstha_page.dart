import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/paginated_list_view.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj_sanstha.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_sanstha_controller.dart';

class SamajSansthaPage extends StatefulWidget {
  const SamajSansthaPage({super.key});

  @override
  State<SamajSansthaPage> createState() => _SamajSansthaPageState();
}

class _SamajSansthaPageState extends State<SamajSansthaPage> {
  final SamajSansthaController _controller = Get.find<SamajSansthaController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LK.samajSansthas.tr)),
      body: Column(
        children: [
          _buildHeader(_controller),
          Expanded(
            child: PaginatedListView<SamajSanstha, SamajSansthaController>(
              padding: EdgeInsets.zero,
              emptyMessage: 'No items found',
              itemBuilder: (context, index, sanstha) =>
                  _SansthaCard(sanstha: sanstha),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SamajSansthaController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.account_balance_rounded,
              size: 80,
              color: AppColors.white.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  LK.community.tr.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.orange,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                LK.samajSansthas.tr,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                LK.samajSansthaDescription.tr,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontSize: 12.sp,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SansthaCard extends StatefulWidget {
  const _SansthaCard({required this.sanstha});

  final SamajSanstha sanstha;

  @override
  State<_SansthaCard> createState() => _SansthaCardState();
}

class _SansthaCardState extends State<_SansthaCard> {
  bool _isExpanded = false;

  String _getInitials(String name) {
    final cleanName = name.split('(').first.trim();
    final parts = cleanName
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(widget.sanstha.name);
    final hasDescription =
        widget.sanstha.description.isNotEmpty ||
        widget.sanstha.descriptionEnglish.isNotEmpty;

    final descriptionText = widget.sanstha.description.isNotEmpty
        ? widget.sanstha.description
        : widget.sanstha.descriptionEnglish;

    final showEnglishSubtitle =
        widget.sanstha.nameEnglish.isNotEmpty &&
        widget.sanstha.nameEnglish.toLowerCase() !=
            widget.sanstha.name.toLowerCase();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _isExpanded
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.black.withValues(alpha: 0.03),
            blurRadius: _isExpanded ? 16 : 8,
            offset: _isExpanded ? const Offset(0, 8) : const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _isExpanded
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.grey.shade100,
          width: _isExpanded ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: hasDescription
              ? () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.sanstha.name,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          if (showEnglishSubtitle) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.sanstha.nameEnglish,
                              style: TextStyle(
                                color: AppColors.grey.shade500,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (widget.sanstha.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.green.shade100,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Active',
                                  style: TextStyle(
                                    color: AppColors.green.shade700,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (hasDescription) ...[
                          const SizedBox(height: 6),
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.grey.shade400,
                              size: 24,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (hasDescription)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: _isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Divider(
                                color: AppColors.grey.shade100,
                                height: 1,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                descriptionText,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                              if (widget
                                      .sanstha
                                      .descriptionEnglish
                                      .isNotEmpty &&
                                  widget.sanstha.descriptionEnglish !=
                                      widget.sanstha.description) ...[
                                const SizedBox(height: 8),
                                Text(
                                  widget.sanstha.descriptionEnglish,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.grey.shade500,
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    final copyContent =
                                        '${widget.sanstha.name}\n\n$descriptionText';
                                    Clipboard.setData(
                                      ClipboardData(text: copyContent),
                                    ).then((_) {
                                      Get.snackbar(
                                        LK.success.tr,
                                        'Organization details copied to clipboard.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: AppColors.black
                                            .withValues(alpha: 0.8),
                                        colorText: AppColors.white,
                                        margin: const EdgeInsets.all(16),
                                        borderRadius: 8,
                                        duration: const Duration(seconds: 2),
                                      );
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(
                                    Icons.copy_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  label: const Text(
                                    'Copy',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
