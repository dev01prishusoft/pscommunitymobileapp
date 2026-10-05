import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/custom_dropdown_form_field.dart';
import 'package:pscommunitymobileapp/core/widgets/profile_update_status_badge.dart';
import 'package:pscommunitymobileapp/core/models/profile_update_status.dart';

class AppFormDropdown<T> extends StatelessWidget {
  const AppFormDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
    this.hint,
    this.isRequired = false,
    this.validator,
    this.requiredErrorMessage,
    this.updateStatus,
    this.originalValue,
    this.enableSearch = true,
    this.enableAdd = false,
    this.onAdd,
    this.searchHint,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String label;
  final String? hint;
  final bool isRequired;
  final String? Function(T?)? validator;
  final String? requiredErrorMessage;
  final ProfileUpdateStatus? updateStatus;
  final T? originalValue;
  final bool enableSearch;
  final bool enableAdd;
  final VoidCallback? onAdd;
  final String? searchHint;

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
    final cleanLabel = label.replaceAll('*', '').trim();

    showDialog(
      context: context,
      builder: (dialogContext) {
        String query = '';
        final searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final q = query.trim().toLowerCase();
            final filteredItems = items.where((item) {
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
                    if (enableSearch || enableAdd) ...[
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
                        child: Row(
                          children: [
                            if (enableSearch)
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
                              )
                            else
                              const Spacer(),
                            if (enableSearch && enableAdd)
                              SizedBox(width: 10.w),
                            if (enableAdd)
                              InkWell(
                                onTap: () {
                                  Navigator.of(dialogContext).pop();
                                  onAdd?.call();
                                },
                                borderRadius: BorderRadius.circular(8.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 4.h,
                                  ),
                                  child: Text(
                                    LK.Add.tr,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
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
                                horizontal: 24.w,
                                vertical: 36.h,
                              ),
                              child: Column(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.red,
                  ),
                ),
            ],
          ),
        ).paddingOnly(left: 5.w, bottom: 6.h),
        Listener(
          onPointerDown: (_) =>
              FocusScope.of(context).requestFocus(FocusNode()),
          child: Stack(
            children: [
              CustomDropdownFormField<T>(
                value: value,
                items: items,
                onChanged: onChanged,
                menuMaxHeight: 350,
                hint: hint,
                enableSearch: false,
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((DropdownMenuItem<T> item) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: item.child,
                    );
                  }).toList();
                },
                validator: (val) {
                  if (isRequired && val == null) {
                    if (originalValue == null) {
                      return requiredErrorMessage ??
                          '${label.replaceAll('*', '').trim()} ${LK.isRequired.tr}';
                    }
                  }
                  if (isRequired && val is String && val.trim().isEmpty) {
                    if (originalValue != null &&
                        originalValue is String &&
                        (originalValue as String).trim().isEmpty) {
                    } else {
                      return requiredErrorMessage ??
                          '${label.replaceAll('*', '').trim()} ${LK.isRequired.tr}';
                    }
                  }
                  if (validator != null) {
                    return validator!(val);
                  }
                  return null;
                },
              ),
              if (enableSearch || enableAdd)
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
          ),
        ),
        if (updateStatus != null)
          ProfileUpdateStatusBadge(status: updateStatus!),
      ],
    );
  }
}
