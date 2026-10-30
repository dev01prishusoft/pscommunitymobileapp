import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/models/library_item_details_model.dart';
import 'package:pscommunitymobileapp/core/models/library_item_model.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/utils/date_formatter.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/features/library/controllers/library_controller.dart';

class LibraryTextViewerPage extends StatefulWidget {
  const LibraryTextViewerPage({super.key});

  @override
  State<LibraryTextViewerPage> createState() => _LibraryTextViewerPageState();
}

class _LibraryTextViewerPageState extends State<LibraryTextViewerPage> {
  late LibraryItemModel item;
  LibraryItemDetailsData? _details;
  bool _isLoadingDetails = false;
  int _selectedFileIndex = 0;

  double _fontSize = 17.0;

  List<LibraryItemFile> get _files => _details?.files ?? <LibraryItemFile>[];
  LibraryItemFile? get _currentFile =>
      _files.isNotEmpty && _selectedFileIndex < _files.length
          ? _files[_selectedFileIndex]
          : null;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is LibraryItemModel) {
      item = args;
    } else if (args is int) {
      item = LibraryItemModel(id: args.toString(), libraryItemId: args);
    } else if (args is String) {
      item = LibraryItemModel(id: args, libraryItemId: int.tryParse(args));
    } else {
      item = LibraryItemModel();
    }
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final libraryController = Get.isRegistered<LibraryController>()
        ? Get.find<LibraryController>()
        : Get.put(LibraryController());
    final itemId = item.libraryItemId ?? int.tryParse(item.id);
    if (itemId != null) {
      setState(() => _isLoadingDetails = true);
      final details = await libraryController.fetchItemDetails(itemId);
      if (mounted) {
        setState(() {
          _details = details;
          _isLoadingDetails = false;
          if (_files.isNotEmpty) {
            final primaryIdx = _files.indexWhere((f) => f.isPrimary == true);
            if (primaryIdx != -1) {
              _selectedFileIndex = primaryIdx;
            }
          }
        });
      }
    }
  }

  void _switchSection(int index) {
    if (index < 0 || index >= _files.length) return;
    setState(() {
      _selectedFileIndex = index;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSize > 13.0) _fontSize -= 2.0;
    });
  }

  void _increaseFontSize() {
    setState(() {
      if (_fontSize < 28.0) _fontSize += 2.0;
    });
  }

  void _copyText(String textContent, String? displayMeaning) {
    final displayTitle = _details?.title ?? item.contentTitle ?? item.title;
    final buffer = StringBuffer(displayTitle);
    if (textContent.isNotEmpty && textContent != LK.library_text_empty_content.tr) {
      buffer.write('\n\n$textContent');
    }
    if (displayMeaning != null && displayMeaning.isNotEmpty) {
      buffer.write('\n\n${LK.library_text_meaning_heading.tr}:\n$displayMeaning');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    PSDelightToastBar(
      snackbarDuration: const Duration(seconds: 2),
      builder: (context) => ToastCard(
        title: LK.library_text_copied_title.tr,
        subtitle: LK.library_text_copied_msg.tr,
      ),
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = _details?.title ?? item.title;
    final rawDate = _details?.publishedOn ?? item.date;
    final displayDate = formatDateString(rawDate, fallback: '');
    final badgeText =
        _details?.contentTypeBadge ?? _details?.contentTypeName ?? LK.library_text_badge_fallback.tr;

    final bodyStr = _details?.bodyText?.toString().trim();
    final descStr = _details?.description?.trim();
    final shortDescStr = _details?.shortDescription?.trim();
    final itemContent = item.content?.trim() ?? '';
    final itemMeaning = item.meaning?.trim();

    final String textContent;
    final String? displayMeaning;

    if (bodyStr != null && bodyStr.isNotEmpty) {
      textContent = bodyStr;
      if (descStr != null && descStr.isNotEmpty && descStr != bodyStr) {
        displayMeaning = descStr;
      } else if (shortDescStr != null &&
          shortDescStr.isNotEmpty &&
          shortDescStr != bodyStr) {
        displayMeaning = shortDescStr;
      } else if (itemMeaning != null &&
          itemMeaning.isNotEmpty &&
          itemMeaning != bodyStr) {
        displayMeaning = itemMeaning;
      } else {
        displayMeaning = null;
      }
    } else if (itemContent.isNotEmpty) {
      textContent = itemContent;
      if (descStr != null && descStr.isNotEmpty && descStr != itemContent) {
        displayMeaning = descStr;
      } else if (shortDescStr != null &&
          shortDescStr.isNotEmpty &&
          shortDescStr != itemContent) {
        displayMeaning = shortDescStr;
      } else {
        displayMeaning = null;
      }
    } else if (descStr != null && descStr.isNotEmpty) {
      textContent = descStr;
      displayMeaning = null;
    } else {
      textContent = LK.library_text_empty_content.tr;
      displayMeaning = null;
    }

    final bgColor = AppColors.sfBackground;
    final cardBgColor = Colors.white;
    final textColor = const Color(0xFF1E293B);
    final subTextColor = const Color(0xFF64748B);
    final bottomBarBg = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(displayTitle),
      ),
      body: Column(
        children: [
          if (_isLoadingDetails)
            LinearProgressIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              minHeight: 2.h,
            ),

          // Header Card
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayTitle,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        if (displayDate.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            displayDate,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      badgeText,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Multi-section / chapter selector tabs
          if (_files.length > 1)
            Container(
              height: 42.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _files.length,
                itemBuilder: (context, idx) {
                  final file = _files[idx];
                  final isSelected = idx == _selectedFileIndex;
                  final secTitle = file.caption?.isNotEmpty == true
                      ? file.caption!
                      : (file.fileName?.isNotEmpty == true
                          ? file.fileName!
                          : '${LK.library_text_part_fallback.tr} ${idx + 1}');

                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: InkWell(
                      onTap: () => _switchSection(idx),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : cardBgColor,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 14.sp,
                              color: isSelected ? Colors.white : subTextColor,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              secTitle,
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 12.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected ? Colors.white : textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Scrollable Prayer Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content Title
                  if (displayTitle.isNotEmpty) ...[
                    Text(
                      _currentFile?.caption?.isNotEmpty == true
                          ? _currentFile!.caption!
                          : displayTitle,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: (_fontSize + 4).sp,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  // Content Body
                  Text(
                    textContent,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: _fontSize.sp,
                      height: 1.85,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),

                  // Meaning / Translation Section (black bold heading & safe nullable handling)
                  if (displayMeaning != null && displayMeaning.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    const Divider(color: Color(0xFFCBD5E1)),
                    SizedBox(height: 14.h),
                    Text(
                      LK.library_text_meaning_heading.tr,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      displayMeaning,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: (_fontSize - 1).sp,
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],

                  // Attached files / downloads
                  if (_files.isNotEmpty) ...[
                    SizedBox(height: 28.h),
                    const Divider(color: Color(0xFFCBD5E1)),
                    SizedBox(height: 12.h),
                    Text(
                      '${LK.library_text_attachments_heading.tr} (${_files.length}):',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ..._files.map((file) {
                      final titleStr =
                          file.fileName ?? file.caption ?? LK.library_text_attachment_fallback.tr;
                      final sizeStr =
                          LibraryController.formatFileSize(file.fileSizeBytes);

                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.insert_drive_file_outlined,
                                color: AppColors.primary, size: 22.sp),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    titleStr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.titleSmall.copyWith(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  if (sizeStr.isNotEmpty ||
                                      file.caption != null) ...[
                                    SizedBox(height: 2.h),
                                    Text(
                                      [
                                        if (file.caption != null &&
                                            file.caption!.isNotEmpty)
                                          file.caption!,
                                        if (sizeStr.isNotEmpty) sizeStr,
                                      ].join(' • '),
                                      style: AppTextStyles.labelSmall.copyWith(
                                        fontSize: 11.5.sp,
                                        color: subTextColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Bar (Font Size & Copy)
          Container(
            decoration: BoxDecoration(
              color: bottomBarBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: _decreaseFontSize,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                      child: Text(
                        'A-',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${_fontSize.toInt()}pt',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 12.sp,
                      color: subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: _increaseFontSize,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                      child: Text(
                        'A+',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy_rounded,
                      color: textColor,
                      size: 20.sp,
                    ),
                    onPressed: () => _copyText(textContent, displayMeaning),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
