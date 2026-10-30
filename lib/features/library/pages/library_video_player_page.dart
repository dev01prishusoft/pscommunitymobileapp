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
import 'package:pscommunitymobileapp/features/advertisement/widgets/ad_video_player_widget.dart';
import 'package:pscommunitymobileapp/features/library/controllers/library_controller.dart';
import 'package:video_player/video_player.dart';

class LibraryVideoPlayerPage extends StatefulWidget {
  const LibraryVideoPlayerPage({super.key});

  @override
  State<LibraryVideoPlayerPage> createState() => _LibraryVideoPlayerPageState();
}

class _LibraryVideoPlayerPageState extends State<LibraryVideoPlayerPage> {
  late LibraryItemModel item;
  LibraryItemDetailsData? _details;
  bool _isLoadingDetails = false;
  int _selectedFileIndex = 0;

  VideoPlayerController? _activeVideoController;

  bool _isVideoPlaying = false;
  bool _isMuted = false;
  bool _isLandscape = false;

  List<LibraryItemFile> get _files => _details?.files ?? <LibraryItemFile>[];
  LibraryItemFile? get _currentFile =>
      _files.isNotEmpty && _selectedFileIndex < _files.length
          ? _files[_selectedFileIndex]
          : null;

  String get _playableVideoUrl {
    final raw = _currentFile?.filePath ??
        _files.firstOrNull?.filePath ??
        item.videoUrl ??
        item.downloadUrl ??
        item.primaryFilePath ??
        '';
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

  void _switchVideo(int index) {
    if (index < 0 || index >= _files.length) return;
    if (index == _selectedFileIndex) return;

    _activeVideoController?.pause();
    _activeVideoController?.removeListener(_onControllerUpdate);
    _activeVideoController = null;

    setState(() {
      _selectedFileIndex = index;
    });
  }

  void _onControllerUpdate() {
    if (!mounted || _activeVideoController == null) return;
    final isPlaying = _activeVideoController!.value.isPlaying;
    if (isPlaying != _isVideoPlaying) {
      setState(() {
        _isVideoPlaying = isPlaying;
      });
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });

    if (_activeVideoController != null &&
        _activeVideoController!.value.isInitialized) {
      _activeVideoController!.setVolume(_isMuted ? 0.0 : 1.0);
    }
  }

  void _toggleOrientation() {
    final isCurrentlyLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape || _isLandscape;

    setState(() {
      _isLandscape = !isCurrentlyLandscape;
    });

    if (_isLandscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  void dispose() {
    _activeVideoController?.removeListener(_onControllerUpdate);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscapeNow =
        MediaQuery.of(context).orientation == Orientation.landscape || _isLandscape;

    final targetUrl = _playableVideoUrl;
    final displayTitle = _details?.title ?? item.videoTitle ?? item.title;
    final displayDescription = _details?.description ??
        _details?.shortDescription ??
        item.about ??
        (item.description.isNotEmpty ? item.description : LK.library_video_desc_fallback.tr);
    final rawDate = _details?.publishedOn ?? item.date;
    final displayDate = formatDateString(rawDate, fallback: '');

    final videoSurface = _buildVideoSurface(targetUrl, isLandscapeNow, displayTitle);

    return PopScope(
      canPop: !isLandscapeNow,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && isLandscapeNow) {
          _toggleOrientation();
        }
      },
      child: Scaffold(
        backgroundColor: isLandscapeNow ? Colors.black : AppColors.sfBackground,
        appBar: isLandscapeNow
            ? null
            : AppBar(
                title: Text(displayTitle),
              ),
        body: isLandscapeNow
            ? SizedBox.expand(child: videoSurface)
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoadingDetails)
                      LinearProgressIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        minHeight: 2.h,
                      ),

                    // Video Player using AdVideoPlayerWidget
                    videoSurface,

                    // "About this video" Section
                    _buildAboutSection(displayDescription, displayDate),

                    // Multiple Video Files / Episodes Section
                    _buildFilesSection(),

                    if (item.relatedVideos.isNotEmpty) ...[
                      const Divider(color: Color(0xFFE2E8F0), thickness: 1, height: 1),
                      _buildRelatedSection(),
                    ],
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFilesSection() {
    if (_files.isEmpty) return const SizedBox.shrink();

    if (_files.length > 1) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${LK.library_video_collection_heading.tr} (${_files.length})',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  LK.library_video_tap_to_play.tr,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            ..._files.asMap().entries.map((entry) {
              final idx = entry.key;
              final file = entry.value;
              final isSelected = idx == _selectedFileIndex;
              final titleText = file.caption?.isNotEmpty == true
                  ? file.caption!
                  : (file.fileName?.isNotEmpty == true
                      ? file.fileName!
                      : '${LK.library_video_item_fallback.tr} ${idx + 1}');
              final dur =
                  LibraryController.formatDuration(file.durationSeconds);
              final size =
                  LibraryController.formatFileSize(file.fileSizeBytes);
              final meta = [
                if (dur.isNotEmpty) dur,
                if (size.isNotEmpty) size,
              ].join(' • ');

              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _switchVideo(idx),
                    borderRadius: BorderRadius.circular(14.r),
                    child: Padding(
                      padding: EdgeInsets.all(10.r),
                      child: Row(
                        children: [
                          Container(
                            width: 70.w,
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFD4973B)
                                      .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: Icon(
                                isSelected
                                    ? Icons.play_arrow_rounded
                                    : Icons.smart_display_rounded,
                                size: 26.sp,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF8D4708),
                              ),
                            ),
                          ),
                          SizedBox(width: 14.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titleText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleSmall.copyWith(
                                    fontSize: 13.5.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.primary
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                                if (meta.isNotEmpty) ...[
                                  SizedBox(height: 3.h),
                                  Text(
                                    meta,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          if (isSelected)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                LK.library_audio_playing_badge.tr,
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFF94A3B8),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    } else {
      final file = _files.first;
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.video_file_outlined,
                  color: Color(0xFF64748B), size: 20),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  file.fileName ?? LK.library_video_file_fallback.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              if (file.fileSizeBytes != null)
                Text(
                  LibraryController.formatFileSize(file.fileSizeBytes),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildVideoSurface(String targetUrl, bool isLandscape, [String? title]) {
    final displayTitle = title ?? (_details?.title ?? item.videoTitle ?? item.title);
    if (targetUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: isLandscape ? double.infinity : 230.h,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off_rounded, color: Colors.white60, size: 48.sp),
              SizedBox(height: 8.h),
              Text(
                LK.library_video_unavailable_stream.tr,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70, fontSize: 13.sp),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: isLandscape ? double.infinity : 230.h,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Same AdVideoPlayerWidget as used in Advertisement
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: AdVideoPlayerWidget(
                key: ValueKey(targetUrl),
                videoUrl: targetUrl,
                thumbnailUrl: item.thumbnail,
                autoPlay: true,
                fit: BoxFit.contain,
                showProgressBar: true,
                onControllerCreated: (ctrl) {
                  _activeVideoController?.removeListener(_onControllerUpdate);
                  _activeVideoController = ctrl;
                  _activeVideoController?.addListener(_onControllerUpdate);
                  if (_isMuted) {
                    _activeVideoController?.setVolume(0.0);
                  }
                },
                onPlaybackChanged: (isPlaying) {
                  if (mounted && _isVideoPlaying != isPlaying) {
                    setState(() {
                      _isVideoPlaying = isPlaying;
                    });
                  }
                },
              ),
            ),
          ),

          // 2. Top-bar controls (in Landscape: Back button + title)
          if (isLandscape)
            Positioned(
              top: 14,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleOrientation,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayTitle,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(color: Colors.black87, blurRadius: 6),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // 3. Bottom Quick Controls: Mute/Unmute & Fullscreen/Rotate Buttons
          Positioned(
            bottom: isLandscape ? 12 : 8.h,
            right: isLandscape ? 20 : 12.w,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mute / Unmute Button (Left of Fullscreen)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleMute,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(isLandscape ? 6 : 7.r),
                      decoration: BoxDecoration(
                        color: _isMuted
                            ? const Color(0xFFDC2626).withValues(alpha: 0.85)
                            : Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: isLandscape ? 18 : 20.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isLandscape ? 10 : 10.w),

                // Fullscreen / Rotate Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleOrientation,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(isLandscape ? 6 : 7.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isLandscape
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: isLandscape ? 19 : 21.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(String displayDescription, String displayDate) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  LK.library_video_about_heading.tr,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              if (displayDate.isNotEmpty)
                Text(
                  displayDate,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            displayDescription,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13.sp,
              height: 1.5,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedSection() {
    final relatedList = item.relatedVideos;
    if (relatedList.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LK.library_video_related_heading.tr,
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 12.h),

          ...relatedList.map((rel) {
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final nextUrl = LibraryController.resolveMediaUrl(rel.videoUrl);
                    _activeVideoController?.pause();
                    _activeVideoController?.removeListener(_onControllerUpdate);
                    _activeVideoController = null;
                    setState(() {
                      item = item.copyWith(
                        title: rel.title,
                        videoTitle: rel.title,
                        duration: rel.duration,
                        videoUrl: nextUrl,
                        thumbnail: rel.thumbnail,
                      );
                    });
                  },
                  borderRadius: BorderRadius.circular(14.r),
                  child: Padding(
                    padding: EdgeInsets.all(10.r),
                    child: Row(
                      children: [
                        Container(
                          width: 80.w,
                          height: 54.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4973B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.temple_hindu_rounded,
                              size: 28.sp,
                              color: const Color(0xFF8D4708),
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rel.title,
                                style: AppTextStyles.titleSmall.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                rel.duration,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
