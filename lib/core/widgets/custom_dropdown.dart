import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/dropdown_item.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isEnabled = true,
    this.isLoading = false,
    this.height,
    this.fillColor,
    this.padding,
    this.iconSize,
    this.style,
    this.isExpanded = true,
    this.enableSearch = true,
    this.enableAdd = false,
    this.onAdd,
    this.onAddQuery,
    this.searchHint,
    this.label,
  });

  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final bool isEnabled;
  final bool isLoading;
  final double? height;
  final Color? fillColor;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;
  final TextStyle? style;
  final bool isExpanded;
  final bool enableSearch;
  final bool enableAdd;
  final VoidCallback? onAdd;
  final void Function(String)? onAddQuery;
  final String? searchHint;
  final String? label;

  Widget _buildAddOptionCard({
    required String query,
    required String displayField,
    required BuildContext dialogContext,
  }) {
    final cleanQuery = query.trim();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (cleanQuery.isEmpty) return;
          Navigator.of(dialogContext).pop();
          onAddQuery?.call(cleanQuery);
          onAdd?.call();
          if (cleanQuery is T) {
            onChanged?.call(cleanQuery as T);
          } else if (T == DropdownItem || <DropdownItem>[] is List<T>) {
            onChanged?.call(DropdownItem(id: 0, text: cleanQuery) as T);
          }
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F5FF),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFC7DBFE), width: 1.2.w),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          const TextSpan(text: 'Add '),
                          if (cleanQuery.isNotEmpty) ...[
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 1.5.h,
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color: AppColors.grey.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1.w,
                                  ),
                                ),
                                child: Text(
                                  '"$cleanQuery"',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: ' '),
                          ],
                          TextSpan(
                            text: cleanQuery.isNotEmpty
                                ? 'as new $displayField'
                                : 'new $displayField',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Click to add and select',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractText(Widget widget) {
    if (widget is Text) {
      return widget.data ?? widget.textSpan?.toPlainText() ?? '';
    }
    if (widget is RichText) {
      return widget.text.toPlainText();
    }
    if (widget is FittedBox && widget.child != null) {
      return _extractText(widget.child!);
    }
    if (widget is Padding && widget.child != null) {
      return _extractText(widget.child!);
    }
    if (widget is Container && widget.child != null) {
      return _extractText(widget.child!);
    }
    if (widget is Align && widget.child != null) {
      return _extractText(widget.child!);
    }
    if (widget is Center && widget.child != null) {
      return _extractText(widget.child!);
    }
    if (widget is Flexible) {
      return _extractText(widget.child);
    }
    if (widget is SizedBox && widget.child != null) {
      return _extractText(widget.child!);
    }
    if (widget is Row) {
      return widget.children.map(_extractText).join(' ');
    }
    if (widget is Column) {
      return widget.children.map(_extractText).join(' ');
    }
    return '';
  }

  void _showSearchDialog(BuildContext context) {
    final cleanLabel = (label ?? hint).replaceAll('*', '').trim();
    final canAdd = enableAdd || onAdd != null || onAddQuery != null;
    final displayField = cleanLabel.isNotEmpty ? cleanLabel : 'Item';

    showDialog(
      context: context,
      builder: (dialogContext) {
        String query = '';
        final searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final q = query.trim().toLowerCase();
            final allItems =
                (value != null && !items.any((o) => o.value == value))
                ? [
                    DropdownMenuItem<T>(
                      value: value,
                      child: Text(
                        value is DropdownItem
                            ? (value as DropdownItem).text
                            : value.toString(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    ...items,
                  ]
                : items;
            final filteredItems = allItems.where((item) {
              if (q.isEmpty) return true;
              final text = _extractText(item.child).toLowerCase();
              final val = (item.value?.toString() ?? '').toLowerCase();
              return text.contains(q) || val.contains(q);
            }).toList();

            return Dialog(
              backgroundColor: AppColors.white,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 24.h,
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (enableSearch) ...[
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                autofocus: true,
                                onChanged: (val) {
                                  setDialogState(() {
                                    query = val;
                                  });
                                },
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.black,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText:
                                      searchHint ??
                                      '${LK.Search.tr} $cleanLabel...',
                                  hintStyle: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.grey.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    size: 20.sp,
                                    color: AppColors.primary,
                                  ),
                                  suffixIcon: query.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.cancel_rounded,
                                            size: 18.sp,
                                            color: AppColors.grey,
                                          ),
                                          onPressed: () {
                                            searchController.clear();
                                            setDialogState(() {
                                              query = '';
                                            });
                                          },
                                        )
                                      : null,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 10.h,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.sfBackground,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      width: 1.w,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      width: 1.w,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 1.2.w,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.grey.withValues(alpha: 0.2),
                      ),
                    ],

                    // Options List / Empty State
                    Flexible(
                      child: filteredItems.isEmpty
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: canAdd ? 16.w : 24.w,
                                vertical: canAdd ? 16.h : 36.h,
                              ),
                              child: canAdd
                                  ? _buildAddOptionCard(
                                      query: query,
                                      displayField: displayField,
                                      dialogContext: dialogContext,
                                    )
                                  : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16.r),
                                    decoration: BoxDecoration(
                                      color: AppColors.grey.withValues(
                                        alpha: 0.08,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      query.trim().isNotEmpty
                                          ? Icons.search_off_rounded
                                          : Icons.inbox_outlined,
                                      size: 36.sp,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    query.trim().isNotEmpty
                                        ? LK.noMatchesFound.tr
                                        : LK.noDataFound.tr,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    query.trim().isNotEmpty
                                        ? '${LK.noResultsFound.tr} "$query"'
                                        : (cleanLabel.isNotEmpty
                                              ? '${LK.noResultsFound.tr} $cleanLabel'
                                              : LK.noResultsFound.tr),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              itemCount: filteredItems.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                thickness: 0.5,
                                color: AppColors.grey.withValues(alpha: 0.12),
                              ),
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final isSelected = item.value == value;

                                return Material(
                                  color: isSelected
                                      ? AppColors.primary.withValues(
                                          alpha: 0.08,
                                        )
                                      : Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(dialogContext).pop();
                                      onChanged?.call(item.value);
                                    },
                                    child: Container(
                                      decoration: isSelected
                                          ? BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                  color: AppColors.primary,
                                                  width: 3.5.w,
                                                ),
                                              ),
                                            )
                                          : null,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 14.h,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(child: item.child),
                                          if (isSelected) ...[
                                            SizedBox(width: 8.w),
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 20.sp,
                                              color: AppColors.primary,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMatchingItem = value != null && items.any((o) => o.value == value);
    final effectiveItems = (value != null && !hasMatchingItem)
        ? [
            DropdownMenuItem<T>(
              value: value,
              child: Text(
                value is DropdownItem
                    ? (value as DropdownItem).text
                    : value.toString(),
                style:
                    style ??
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.black),
              ),
            ),
            ...items,
          ]
        : items;
    final safeValue =
        (value != null && effectiveItems.any((o) => o.value == value))
        ? effectiveItems.firstWhere((o) => o.value == value).value
        : null;

    final dropdownWidget = Container(
      height: height ?? 52.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            fillColor ??
            (isEnabled
                ? AppColors.white
                : AppColors.grey.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.primary, width: 1.w,
        ),
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: safeValue,
          hint: Text(
            hint,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey.withValues(alpha: 0.6),
            ),
          ),
          style:
              style ??
              AppTextStyles.bodyMedium.copyWith(color: AppColors.black),
          isExpanded: isExpanded,
          icon: isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                )
              : Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grey,
                  size: iconSize ?? 20.sp,
                ),
          items: effectiveItems.isEmpty ? null : effectiveItems,
          onChanged: isEnabled ? onChanged : null,
          borderRadius: BorderRadius.circular(14.r),
          dropdownColor: AppColors.white,
          elevation: 8,
          menuMaxHeight: 350,
          isDense: true,
        ),
      ),
    );

    if (isEnabled && !isLoading && (enableSearch || enableAdd)) {
      return Stack(
        children: [
          dropdownWidget,
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14.r),
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  _showSearchDialog(context);
                },
              ),
            ),
          ),
        ],
      );
    }

    return dropdownWidget;
  }
}
