import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pscommunitymobileapp/core/models/library_item_details_model.dart';
import 'package:pscommunitymobileapp/core/models/library_item_model.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/features/library/controllers/library_controller.dart';

class LibraryPdfViewerPage extends StatefulWidget {
  const LibraryPdfViewerPage({super.key});

  @override
  State<LibraryPdfViewerPage> createState() => _LibraryPdfViewerPageState();
}

class _LibraryPdfViewerPageState extends State<LibraryPdfViewerPage> {
  late LibraryItemModel item;
  LibraryItemDetailsData? _details;
  bool _isLoadingDetails = false;
  Uint8List? _pdfBytes;
  bool _isLoadingPdfBytes = false;
  int _selectedFileIndex = 0;

  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(1);
  final ValueNotifier<int> _totalPagesNotifier = ValueNotifier<int>(1);

  final ScrollController _pdfScrollController = ScrollController();
  List<PdfPreviewPageData>? _currentRenderedPages;
  double? _currentContainerWidth;
  int? _zoomedPageIndex;

  List<LibraryItemFile> get _files => _details?.files ?? <LibraryItemFile>[];
  LibraryItemFile? get _currentFile =>
      _files.isNotEmpty && _selectedFileIndex < _files.length
          ? _files[_selectedFileIndex]
          : null;

  String? get _resolvedPdfUrl {
    final raw = _currentFile?.filePath ??
        _files.firstOrNull?.filePath ??
        item.downloadUrl ??
        item.primaryFilePath ??
        '';
    if (raw.isEmpty) return null;
    return LibraryController.resolveMediaUrl(raw);
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
    _totalPagesNotifier.value = item.totalPages ?? 1;
    _fetchDetails();
  }

  @override
  void dispose() {
    _pdfScrollController.dispose();
    _currentPageNotifier.dispose();
    _totalPagesNotifier.dispose();
    if (_currentRenderedPages != null) {
      for (final p in _currentRenderedPages!) {
        p.image.evict();
      }
      _currentRenderedPages = null;
    }
    super.dispose();
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

          final pCount = _currentFile?.pageCount ?? details?.pageCount;
          if (pCount != null) {
            final parsed = int.tryParse(pCount.toString());
            if (parsed != null && parsed > 0) {
              _totalPagesNotifier.value = parsed;
            }
          }
        });
      }
    }

    final pdfUrl = _resolvedPdfUrl;
    if (pdfUrl != null && pdfUrl.isNotEmpty) {
      _loadPdfData(pdfUrl);
    }
  }

  void _switchPdf(int index) {
    if (index < 0 || index >= _files.length) return;
    if (index == _selectedFileIndex) return;

    if (_currentRenderedPages != null) {
      for (final p in _currentRenderedPages!) {
        p.image.evict();
      }
      _currentRenderedPages = null;
    }

    setState(() {
      _selectedFileIndex = index;
      _currentPageNotifier.value = 1;
      _zoomedPageIndex = null;
      _pdfBytes = null;
      final pCount = _currentFile?.pageCount;
      if (pCount != null) {
        final parsed = int.tryParse(pCount.toString());
        if (parsed != null && parsed > 0) {
          _totalPagesNotifier.value = parsed;
        }
      }
    });

    if (_pdfScrollController.hasClients) {
      _pdfScrollController.jumpTo(0);
    }

    final url = _resolvedPdfUrl;
    if (url != null && url.isNotEmpty) {
      _loadPdfData(url);
    }
  }

  Future<void> _loadPdfData(String url) async {
    if (!url.toLowerCase().endsWith('.pdf') && !url.toLowerCase().contains('.pdf')) {
      return;
    }
    setState(() => _isLoadingPdfBytes = true);
    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null && mounted) {
        setState(() {
          _pdfBytes = Uint8List.fromList(response.data!);
          _isLoadingPdfBytes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPdfBytes = false);
      }
    }
  }

  Uint8List _buildPdfDocument(PdfPageFormat format) => _pdfBytes!;

  void _updateCurrentPage(
    ScrollMetrics metrics,
    List<PdfPreviewPageData> pages,
    double maxWidth,
  ) {
    if (pages.isEmpty) return;

    int newPage;
    if (metrics.pixels <= 15) {
      newPage = 1;
    } else if (metrics.pixels >= metrics.maxScrollExtent - 15) {
      newPage = pages.length;
    } else {
      final pageWidth = maxWidth - 24.w;
      final focalOffset = metrics.pixels + (metrics.viewportDimension * 0.35);

      double cumulativeTop = 8.h;
      newPage = 1;
      for (int i = 0; i < pages.length; i++) {
        final ar = pages[i].aspectRatio;
        final effectiveAr = (ar.isFinite && ar > 0) ? ar : 0.75;
        final itemHeight = (pageWidth / effectiveAr) + 12.h;
        final itemBottom = cumulativeTop + itemHeight;

        if (focalOffset >= cumulativeTop && focalOffset < itemBottom) {
          newPage = i + 1;
          break;
        }
        cumulativeTop = itemBottom;
      }
    }

    newPage = newPage.clamp(1, pages.length);
    if (newPage != _currentPageNotifier.value) {
      _currentPageNotifier.value = newPage;
    }
  }

  void _jumpToPage(int targetPage) {
    final pages = _currentRenderedPages;
    final width = _currentContainerWidth;
    if (pages == null || pages.isEmpty || width == null) return;

    final clampedPage = targetPage.clamp(1, pages.length);
    final pageWidth = width - 24.w;

    double offset = 0;
    if (clampedPage > 1) {
      offset = 8.h;
      for (int i = 0; i < clampedPage - 1; i++) {
        final ar = pages[i].aspectRatio;
        final effectiveAr = (ar.isFinite && ar > 0) ? ar : 0.75;
        offset += (pageWidth / effectiveAr) + 12.h;
      }
    }

    if (_pdfScrollController.hasClients) {
      final maxScroll = _pdfScrollController.position.maxScrollExtent;
      final targetOffset = offset.clamp(0.0, maxScroll);
      _pdfScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showGoToPageDialog() {
    final controller = TextEditingController(
      text: '${_currentPageNotifier.value}',
    );
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Go to page (1 - ${_totalPagesNotifier.value})',
                style: AppTextStyles.titleSmall.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  hintText: 'Page number',
                  hintStyle: const TextStyle(color: Colors.white38),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: () {
                      final page = int.tryParse(controller.text.trim());
                      Get.back();
                      if (page != null) {
                        _jumpToPage(page);
                      }
                    },
                    child: const Text(
                      'Go',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfPages(BuildContext context, List<PdfPreviewPageData> pages) {
    if (pages.isNotEmpty) {
      _currentRenderedPages = pages;
      if (pages.length > _totalPagesNotifier.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && pages.length > _totalPagesNotifier.value) {
            _totalPagesNotifier.value = pages.length;
          }
        });
      }
    }

    if (_zoomedPageIndex != null && _zoomedPageIndex! < pages.length) {
      final page = pages[_zoomedPageIndex!];
      final ar = (page.aspectRatio.isFinite && page.aspectRatio > 0)
          ? page.aspectRatio
          : 0.75;

      return GestureDetector(
        onDoubleTap: () => setState(() => _zoomedPageIndex = null),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(16.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AspectRatio(
                    aspectRatio: ar,
                    child: Image(image: page.image, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12.h,
              right: 12.w,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => setState(() => _zoomedPageIndex = null),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'Page ${_zoomedPageIndex! + 1} of ${pages.length}',
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _currentContainerWidth = constraints.maxWidth;
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            _updateCurrentPage(
              notification.metrics,
              pages,
              constraints.maxWidth,
            );
            return false;
          },
          child: ListView.builder(
            controller: _pdfScrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final page = pages[index];
              final ar = (page.aspectRatio.isFinite && page.aspectRatio > 0)
                  ? page.aspectRatio
                  : 0.75;

              return GestureDetector(
                onDoubleTap: () => setState(() => _zoomedPageIndex = index),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 2),
                        blurRadius: 6,
                        color: Color.fromRGBO(0, 0, 0, 0.35),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatio(
                    aspectRatio: ar,
                    child: Image(image: page.image, fit: BoxFit.contain),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = _details?.title ?? item.title;
    return PopScope(
      canPop: _zoomedPageIndex == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _zoomedPageIndex != null) {
          setState(() => _zoomedPageIndex = null);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E293B),
        appBar: AppBar(title: Text(displayTitle)),
        body: Column(
          children: [
            if (_isLoadingDetails || _isLoadingPdfBytes)
              LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                minHeight: 2.h,
              ),

            // Multi-document selector dropdown when multiple files exist
            if (_files.length > 1)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: const BoxDecoration(
                  color: Color(0xFF0A0F1D),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value:
                          (_selectedFileIndex >= 0 &&
                              _selectedFileIndex < _files.length)
                          ? _selectedFileIndex
                          : 0,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E293B),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white70,
                      ),
                      items: List.generate(_files.length, (idx) {
                        final file = _files[idx];
                        final docTitle = file.caption?.isNotEmpty == true
                            ? file.caption!
                            : (file.fileName?.isNotEmpty == true
                                  ? file.fileName!
                                  : '${LK.library_pdf_dropdown_fallback.tr} ${idx + 1}');
                        final pCount = file.pageCount != null
                            ? ' (${file.pageCount} ${LK.library_pdf_pages_tag.tr})'
                            : '';

                        return DropdownMenuItem<int>(
                          value: idx,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf_rounded,
                                size: 18,
                                color: Color(0xFFEF4444),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  '$docTitle$pCount',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleSmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: idx == _selectedFileIndex
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      onChanged: (newIdx) {
                        if (newIdx != null) {
                          _switchPdf(newIdx);
                        }
                      },
                    ),
                  ),
                ),
              ),

            // Sub Toolbar (Dark bar: [ < ] [ 1 ] [ > ] / 24)
            Container(
              color: const Color(0xFF0F172A),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: ValueListenableBuilder<int>(
                valueListenable: _currentPageNotifier,
                builder: (context, currentPage, _) {
                  return ValueListenableBuilder<int>(
                    valueListenable: _totalPagesNotifier,
                    builder: (context, totalPages, _) {
                      final canGoPrev = currentPage > 1;
                      final canGoNext = currentPage < totalPages;

                      return Row(
                        children: [
                          // Previous page button
                          InkWell(
                            onTap: canGoPrev
                                ? () => _jumpToPage(currentPage - 1)
                                : null,
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: canGoPrev
                                    ? const Color(0xFF1E293B)
                                    : const Color(
                                        0xFF1E293B,
                                      ).withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: canGoPrev
                                      ? const Color(0xFF334155)
                                      : const Color(
                                          0xFF334155,
                                        ).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: 18.sp,
                                color: canGoPrev
                                    ? Colors.white
                                    : Colors.white24,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          // Page indicator container (tap to enter page number)
                          InkWell(
                            onTap: _showGoToPageDialog,
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              constraints: BoxConstraints(minWidth: 34.w),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: const Color(0xFF334155),
                                ),
                              ),
                              child: Text(
                                '$currentPage',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          // Next page button
                          InkWell(
                            onTap: canGoNext
                                ? () => _jumpToPage(currentPage + 1)
                                : null,
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: canGoNext
                                    ? const Color(0xFF1E293B)
                                    : const Color(
                                        0xFF1E293B,
                                      ).withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: canGoNext
                                      ? const Color(0xFF334155)
                                      : const Color(
                                          0xFF334155,
                                        ).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                size: 18.sp,
                                color: canGoNext
                                    ? Colors.white
                                    : Colors.white24,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '/ $totalPages',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // PDF Document Viewer Area
            Expanded(
              child: _pdfBytes != null
                  ? PdfPreview.builder(
                      build: _buildPdfDocument,
                      allowPrinting: false,
                      allowSharing: false,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      canDebug: false,
                      dpi: 75.0,
                      maxPageWidth: MediaQuery.of(context).size.width,
                      pagesBuilder: _buildPdfPages,
                    )
                  : Center(
                      child: (_isLoadingPdfBytes || _isLoadingDetails)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                                SizedBox(height: 14.h),
                                Text(
                                  LK.library_pdf_loading.tr,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white70,
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf_outlined,
                                  size: 56.sp,
                                  color: const Color(0xFF64748B),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  LK.library_pdf_not_available.tr,
                                  style: AppTextStyles.titleSmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
