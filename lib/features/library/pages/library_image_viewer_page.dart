import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/models/library_item_details_model.dart';
import 'package:pscommunitymobileapp/core/models/library_item_model.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/features/library/controllers/library_controller.dart';

class LibraryImageViewerPage extends StatefulWidget {
  const LibraryImageViewerPage({super.key});

  @override
  State<LibraryImageViewerPage> createState() => _LibraryImageViewerPageState();
}

class _LibraryImageViewerPageState extends State<LibraryImageViewerPage> {
  late LibraryItemModel item;
  LibraryItemDetailsData? _details;
  bool _isLoadingDetails = false;

  late final PageController _pageController;
  int _currentIndex = 0;

  List<String> get _photoUrls {
    if (_details?.files != null && _details!.files!.isNotEmpty) {
      final list = <String>[];
      for (final f in _details!.files!) {
        final path = f.filePath ?? f.thumbnailPath?.toString() ?? '';
        if (path.isNotEmpty) {
          list.add(LibraryController.resolveMediaUrl(path));
        }
      }
      if (list.isNotEmpty) return list;
    }
    if (item.photos.isNotEmpty) {
      return item.photos
          .map((p) => LibraryController.resolveMediaUrl(p.url))
          .where((u) => u.isNotEmpty)
          .toList();
    }
    final primary = item.primaryFilePath ?? item.downloadUrl;
    if (primary != null && primary.isNotEmpty) {
      return [LibraryController.resolveMediaUrl(primary)];
    }
    final thumb = item.thumbnailPath?.toString() ?? item.thumbnail;
    if (thumb != null && thumb.isNotEmpty) {
      return [LibraryController.resolveMediaUrl(thumb)];
    }
    return <String>[];
  }

  String? get _currentCaption {
    if (_details?.files != null && _currentIndex < _details!.files!.length) {
      final f = _details!.files![_currentIndex];
      if (f.caption != null && f.caption!.trim().isNotEmpty) {
        return f.caption!.trim();
      }
    }
    if (_currentIndex < item.photos.length &&
        item.photos[_currentIndex].caption != null &&
        item.photos[_currentIndex].caption!.isNotEmpty) {
      return item.photos[_currentIndex].caption;
    }
    if (_details?.description != null && _details!.description!.isNotEmpty) {
      return _details!.description;
    }
    if (item.description.isNotEmpty) {
      return item.description;
    }
    return null;
  }

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
    _pageController = PageController();
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
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    final count = _photoUrls.length;
    if (_currentIndex < count - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = _photoUrls;
    final totalCount = photos.length;
    final displayTitle = _details?.title ??
        (item.title.isNotEmpty ? item.title : LK.library_image_fallback_title.tr);

    final currentFile = (_details?.files != null &&
            _currentIndex < _details!.files!.length)
        ? _details!.files![_currentIndex]
        : null;
    final currentFileName = currentFile?.fileName;
    final displayName = (currentFile?.caption?.trim().isNotEmpty == true)
        ? currentFile!.caption!.trim()
        : ((currentFileName?.trim().isNotEmpty == true)
            ? currentFileName!.trim()
            : ((_currentCaption?.trim().isNotEmpty == true)
                ? _currentCaption!.trim()
                : ''));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
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
          Expanded(
            child: totalCount == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_rounded,
                          size: 64.sp,
                          color: const Color(0xFF64748B),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          LK.library_image_not_available.tr,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Main Image Canvas Area
                      Expanded(
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: totalCount,
                              onPageChanged: (index) {
                                setState(() => _currentIndex = index);
                              },
                              itemBuilder: (context, index) {
                                final photoUrl = photos[index];

                                return InteractiveViewer(
                                  minScale: 1.0,
                                  maxScale: 3.5,
                                  child: Center(
                                    child: photoUrl.isNotEmpty
                                        ? Image.network(
                                            photoUrl,
                                            fit: BoxFit.contain,
                                            loadingBuilder:
                                                (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return _buildFallbackCard(index);
                                            },
                                            errorBuilder: (_, __, ___) =>
                                                _buildFallbackCard(index),
                                          )
                                        : _buildFallbackCard(index),
                                  ),
                                );
                              },
                            ),

                            // Top-right image name & counter pill
                            if (displayName.isNotEmpty || totalCount > 1)
                              Positioned(
                                top: 14.h,
                                right: 14.w,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.72,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (displayName.isNotEmpty)
                                        Flexible(
                                          child: Text(
                                            displayName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.labelMedium.copyWith(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      if (displayName.isNotEmpty &&
                                          totalCount > 1)
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6.w),
                                          child: Text(
                                            '•',
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: Colors.white60,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),
                                      if (totalCount > 1)
                                        Text(
                                          '${_currentIndex + 1}/$totalCount',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: Colors.white70,
                                            fontSize: 11.5.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                            // Previous Arrow Button
                            if (_currentIndex > 0)
                              Positioned(
                                left: 12.w,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: _previousPage,
                                    child: Container(
                                      width: 40.r,
                                      height: 40.r,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.55),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.chevron_left_rounded,
                                        color: Colors.white,
                                        size: 28.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // Next Arrow Button
                            if (_currentIndex < totalCount - 1)
                              Positioned(
                                right: 12.w,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: _nextPage,
                                    child: Container(
                                      width: 40.r,
                                      height: 40.r,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.55),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.white,
                                        size: 28.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),


                      // Horizontal Thumbnail Strip (if multiple images)
                      if (totalCount > 1)
                        Container(
                          height: 72.h,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            itemCount: totalCount,
                            itemBuilder: (context, index) {
                              final isSelected = index == _currentIndex;
                              final thumbUrl = photos[index];

                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  width: 72.w,
                                  margin: EdgeInsets.only(right: 8.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.white24,
                                      width: isSelected ? 2.5 : 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6.r),
                                    child: thumbUrl.isNotEmpty
                                        ? Image.network(
                                            thumbUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Center(
                                              child: Icon(
                                                Icons.photo_rounded,
                                                color: Colors.white60,
                                                size: 22.sp,
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.photo_rounded,
                                              color: Colors.white60,
                                              size: 22.sp,
                                            ),
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
        ],
      ),
    );
  }

  Widget _buildFallbackCard(int index) {
    return Container(
      width: 280.w,
      height: 320.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_rounded,
              size: 56.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(height: 12.h),
            Text(
              item.title.isNotEmpty ? item.title : '${LK.library_image_item_fallback.tr} #${index + 1}',
              style: AppTextStyles.titleSmall.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
