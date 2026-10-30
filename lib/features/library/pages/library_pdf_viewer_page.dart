import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

  int _currentPage = 1;
  late int _totalPages;

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
    _totalPages = item.totalPages ?? 1;
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

          final pCount = _currentFile?.pageCount ?? details?.pageCount;
          if (pCount != null) {
            final parsed = int.tryParse(pCount.toString());
            if (parsed != null && parsed > 0) {
              _totalPages = parsed;
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

    setState(() {
      _selectedFileIndex = index;
      _currentPage = 1;
      _pdfBytes = null;
      final pCount = _currentFile?.pageCount;
      if (pCount != null) {
        final parsed = int.tryParse(pCount.toString());
        if (parsed != null && parsed > 0) {
          _totalPages = parsed;
        }
      }
    });

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
      debugPrint('Error loading PDF bytes: $e');
      if (mounted) {
        setState(() => _isLoadingPdfBytes = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = _details?.title ?? item.title;
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        title: Text(displayTitle),
      ),
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
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: (_selectedFileIndex >= 0 &&
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

          // Sub Toolbar (Dark bar: [ 1 ] / 24, search, fit, more)
          Container(
            color: const Color(0xFF0F172A),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                // Page indicator container
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Text(
                    '$_currentPage',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '/ $_totalPages',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // PDF Document Viewer Area
          Expanded(
            child: _pdfBytes != null
                ? PdfPreview(
                    build: (format) => _pdfBytes!,
                    allowPrinting: false,
                    allowSharing: false,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    previewPageMargin: EdgeInsets.only(top: 5.h),
                    maxPageWidth: MediaQuery.of(context).size.width,
                  )
                : Center(
                    child: (_isLoadingPdfBytes || _isLoadingDetails)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                  color: AppColors.primary),
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
    );
  }
}
