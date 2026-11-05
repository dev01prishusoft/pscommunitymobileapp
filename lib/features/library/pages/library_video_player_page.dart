import 'dart:async';

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
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
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

  VideoPlayerController? _videoController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isMuted = false;
  bool _isLandscape = false;
  bool _showControls = true;
  Timer? _controlsTimer;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isDraggingSeekBar = false;
  double _dragPositionMs = 0;

  final List<double> _speeds = [1.0, 1.25, 1.5, 2.0, 0.75];
  int _speedIndex = 0;

  String? _currentlyLoadedUrl;

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
    _initVideo();
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

        // If the primary file points to a different URL, switch to it
        final newUrl = _playableVideoUrl;
        if (newUrl.isNotEmpty && newUrl != _currentlyLoadedUrl) {
          _setupController(newUrl);
        }
      }
    }
  }

  void _initVideo() {
    final targetUrl = _playableVideoUrl;
    if (targetUrl.isEmpty || targetUrl == _currentlyLoadedUrl) return;
    _setupController(targetUrl);
  }

  Future<void> _setupController(String url) async {
    _currentlyLoadedUrl = url;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
    });

    _controlsTimer?.cancel();
    _videoController?.removeListener(_videoListener);
    final oldController = _videoController;
    _videoController = null;
    oldController?.dispose();

    try {
      final uri = Uri.parse(url);
      final controller = VideoPlayerController.networkUrl(uri);
      _videoController = controller;

      await controller.initialize();
      if (!mounted || _videoController != controller) {
        controller.dispose();
        return;
      }

      controller.addListener(_videoListener);
      if (_isMuted) {
        await controller.setVolume(0.0);
      }
      if (_speedIndex != 0) {
        await controller.setPlaybackSpeed(_speeds[_speedIndex]);
      }
      await controller.play();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _totalDuration = controller.value.duration;
          _currentPosition = controller.value.position;
        });
        _resetControlsTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _videoListener() {
    if (_videoController == null || !mounted) return;
    final val = _videoController!.value;
    if (val.hasError && !_hasError) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      return;
    }

    final pos = val.position;
    final dur = val.duration;
    final isPlaying = val.isPlaying;

    if (!_isDraggingSeekBar) {
      _currentPosition = pos;
    }
    _totalDuration = dur;

    // When video finishes playing, show controls with replay option
    if (dur > Duration.zero && pos >= dur && !isPlaying) {
      _showControls = true;
      _controlsTimer?.cancel();
    }

    setState(() {});
  }

  void _switchVideo(int index) {
    if (index < 0 || index >= _files.length) return;
    if (index == _selectedFileIndex) return;

    setState(() {
      _selectedFileIndex = index;
    });

    final newUrl = _playableVideoUrl;
    if (newUrl.isNotEmpty) {
      _setupController(newUrl);
    }
  }

  void _togglePlayPause() {
    if (_videoController == null || !_videoController!.value.isInitialized)
      return;

    final val = _videoController!.value;
    if (val.duration > Duration.zero && val.position >= val.duration) {
      _videoController!.seekTo(Duration.zero);
      _videoController!.play();
      _resetControlsTimer();
    } else if (val.isPlaying) {
      _videoController!.pause();
      _showControls = true;
      _controlsTimer?.cancel();
    } else {
      _videoController!.play();
      _resetControlsTimer();
    }
    setState(() {});
  }

  void _seekRelative(int seconds) {
    if (_videoController == null || !_videoController!.value.isInitialized)
      return;
    final currentMs = _videoController!.value.position.inMilliseconds;
    final totalMs = _videoController!.value.duration.inMilliseconds;
    final targetMs = (currentMs + (seconds * 1000)).clamp(0, totalMs);
    _videoController!.seekTo(Duration(milliseconds: targetMs));
    _resetControlsTimer();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _videoController?.setVolume(_isMuted ? 0.0 : 1.0);
    _resetControlsTimer();
  }

  void _cycleSpeed() {
    _speedIndex = (_speedIndex + 1) % _speeds.length;
    final speed = _speeds[_speedIndex];
    _videoController?.setPlaybackSpeed(speed);
    setState(() {});
    _resetControlsTimer();
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
    _resetControlsTimer();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _resetControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    if (_videoController?.value.isPlaying == true) {
      _controlsTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _videoController?.value.isPlaying == true) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  static String _formatTime(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
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

    final displayTitle = _details?.title ?? item.videoTitle ?? item.title;
    final displayDescription = _details?.description ??
        _details?.shortDescription ??
        item.about ??
        (item.description.isNotEmpty ? item.description : LK.library_video_desc_fallback.tr);
    final rawDate = _details?.publishedOn ?? item.date;
    final displayDate = formatDateString(rawDate, fallback: '');

    final videoSurface = _buildVideoSurface(isLandscapeNow, displayTitle);

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
            ? Container(
                color: Colors.black,
                width: double.infinity,
                height: double.infinity,
                child: videoSurface,
              )
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

                    // Video Player Surface
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

  Widget _buildVideoSurface(bool isLandscape, [String? title]) {
    final displayTitle =
        title ?? (_details?.title ?? item.videoTitle ?? item.title);
    final targetUrl = _playableVideoUrl;

    if (targetUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: isLandscape ? double.infinity : 225.h,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off_rounded,
                color: Colors.white60,
                size: 48.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                LK.library_video_unavailable_stream.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white70,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isInitialized =
        _videoController != null && _videoController!.value.isInitialized;
    final isPlaying = isInitialized && _videoController!.value.isPlaying;
    final isEnded =
        isInitialized &&
        _totalDuration > Duration.zero &&
        _currentPosition >= _totalDuration;
    final isBuffering = isInitialized && _videoController!.value.isBuffering;

    return Container(
      width: double.infinity,
      height: isLandscape ? double.infinity : 225.h,
      color: Colors.black,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Video Texture
            if (isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio > 0
                      ? _videoController!.value.aspectRatio
                      : 16 / 9,
                  child: VideoPlayer(_videoController!),
                ),
              )
            else if (item.thumbnail != null && item.thumbnail!.isNotEmpty)
              CachedImg(
                url: item.thumbnail!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),

            // 2. Loading / Buffering Indicator
            if (_isLoading || isBuffering)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),

            // 3. Error Overlay
            if (_hasError)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 40.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Failed to load video',
                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () => _setupController(_playableVideoUrl),
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 4. Interactive Controls Overlay (Fades out when not touched)
            if (!_hasError && isInitialized)
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Stack(
                    children: [
                      // Dark gradient background for readability
                      Container(color: Colors.black.withValues(alpha: 0.35)),

                      // Top Bar (Back button in landscape + Video title)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLandscape ? 20 : 12.w,
                            vertical: isLandscape ? 12 : 8.h,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black87, Colors.transparent],
                            ),
                          ),
                          child: SafeArea(
                            bottom: false,
                            child: Row(
                              children: [
                                if (isLandscape) ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ),
                                    onPressed: _toggleOrientation,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Expanded(
                                  child: Text(
                                    displayTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.titleSmall.copyWith(
                                      color: Colors.white,
                                      fontSize: isLandscape ? 14.5 : 13.5.sp,
                                      fontWeight: FontWeight.w700,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black87,
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Center Controls: Rewind 10s | Play/Pause/Replay | Forward 10s
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 10s Rewind
                            IconButton(
                              iconSize: isLandscape ? 36 : 30.sp,
                              color: Colors.white,
                              onPressed: () => _seekRelative(-10),
                              icon: const Icon(Icons.replay_10_rounded),
                              tooltip: 'Rewind 10s',
                            ),
                            SizedBox(width: isLandscape ? 40 : 28.w),

                            // Play / Pause / Replay Center Button
                            GestureDetector(
                              onTap: _togglePlayPause,
                              child: Container(
                                width: isLandscape ? 58 : 52.r,
                                height: isLandscape ? 58 : 52.r,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white70,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  isEnded
                                      ? Icons.replay_rounded
                                      : (isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded),
                                  color: Colors.white,
                                  size: isLandscape ? 34 : 32.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: isLandscape ? 40 : 28.w),

                            // 10s Forward
                            IconButton(
                              iconSize: isLandscape ? 36 : 30.sp,
                              color: Colors.white,
                              onPressed: () => _seekRelative(10),
                              icon: const Icon(Icons.forward_10_rounded),
                              tooltip: 'Forward 10s',
                            ),
                          ],
                        ),
                      ),

                      // Bottom Bar: Progress Scrubber, Timestamps, Speed, Mute, Fullscreen
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                            isLandscape ? 20 : 12.w,
                            10.h,
                            isLandscape ? 20 : 12.w,
                            isLandscape ? 12.h : 6.h,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black87, Colors.transparent],
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Slider Track
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 3.h,
                                    thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 6.r,
                                    ),
                                    overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: 14.r,
                                    ),
                                    activeTrackColor: AppColors.primary,
                                    inactiveTrackColor: Colors.white24,
                                    thumbColor: AppColors.primary,
                                    overlayColor: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                  child: Slider(
                                    min: 0.0,
                                    max:
                                        _totalDuration.inMilliseconds
                                                .toDouble() >
                                            0
                                        ? _totalDuration.inMilliseconds
                                              .toDouble()
                                        : 1.0,
                                    value: _isDraggingSeekBar
                                        ? _dragPositionMs.clamp(
                                            0.0,
                                            _totalDuration.inMilliseconds
                                                .toDouble(),
                                          )
                                        : _currentPosition.inMilliseconds
                                              .toDouble()
                                              .clamp(
                                                0.0,
                                                _totalDuration.inMilliseconds
                                                    .toDouble(),
                                              ),
                                    onChanged: (val) {
                                      setState(() {
                                        _isDraggingSeekBar = true;
                                        _dragPositionMs = val;
                                        _currentPosition = Duration(
                                          milliseconds: val.toInt(),
                                        );
                                      });
                                      _controlsTimer?.cancel();
                                    },
                                    onChangeEnd: (val) {
                                      _isDraggingSeekBar = false;
                                      _videoController?.seekTo(
                                        Duration(milliseconds: val.toInt()),
                                      );
                                      _resetControlsTimer();
                                    },
                                  ),
                                ),

                                // Bottom Row Controls
                                Row(
                                  children: [
                                    // Timestamp: 01:23 / 10:45
                                    Text(
                                      '${_formatTime(_currentPosition)} / ${_formatTime(_totalDuration)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isLandscape ? 12.5 : 11.5.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),

                                    // Playback Speed Button (1x, 1.25x, 1.5x...)
                                    InkWell(
                                      onTap: _cycleSpeed,
                                      borderRadius: BorderRadius.circular(6.r),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),
                                        child: Text(
                                          '${_speeds[_speedIndex]}x',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),

                                    // Mute / Unmute Button
                                    IconButton(
                                      iconSize: isLandscape ? 22 : 20.sp,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        _isMuted
                                            ? Icons.volume_off_rounded
                                            : Icons.volume_up_rounded,
                                        color: Colors.white,
                                      ),
                                      onPressed: _toggleMute,
                                      tooltip: _isMuted ? 'Unmute' : 'Mute',
                                    ),
                                    SizedBox(width: 12.w),

                                    // Fullscreen / Exit Fullscreen Button
                                    IconButton(
                                      iconSize: isLandscape ? 23 : 21.sp,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        isLandscape
                                            ? Icons.fullscreen_exit_rounded
                                            : Icons.fullscreen_rounded,
                                        color: Colors.white,
                                      ),
                                      onPressed: _toggleOrientation,
                                      tooltip: isLandscape
                                          ? 'Exit Fullscreen'
                                          : 'Fullscreen',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
              final dur = LibraryController.formatDuration(
                file.durationSeconds,
              );
              final size = LibraryController.formatFileSize(file.fileSizeBytes);
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
                                  : const Color(
                                      0xFFD4973B,
                                    ).withValues(alpha: 0.2),
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
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
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
              const Icon(
                Icons.video_file_outlined,
                color: Color(0xFF64748B),
                size: 20,
              ),
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
                    final nextUrl = LibraryController.resolveMediaUrl(
                      rel.videoUrl,
                    );
                    setState(() {
                      item = item.copyWith(
                        title: rel.title,
                        videoTitle: rel.title,
                        duration: rel.duration,
                        videoUrl: nextUrl,
                        thumbnail: rel.thumbnail,
                      );
                    });
                    if (nextUrl.isNotEmpty) {
                      _setupController(nextUrl);
                    }
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
